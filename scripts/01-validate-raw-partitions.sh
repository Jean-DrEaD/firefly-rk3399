#!/usr/bin/env bash
# 01-validate-raw-partitions.sh
# Valida via MD5 que as partições raw da Rockchip (p1, p2, p3, p5, p6)
# são idênticas entre o SD e o eMMC.

source "$(dirname "$0")/00-common.sh"

require_root
identify_storage
require_device "$SD_DEVICE"
require_device "$EMMC_DEVICE"
echo

log_info "Validando partições raw (p1, p2, p3, p5, p6) via MD5..."
echo "─────────────────────────────────────────────────────────"

ALL_OK=true
for p in 1 2 3 5 6; do
    sd_part="${SD_DEVICE}p${p}"
    em_part="${EMMC_DEVICE}p${p}"

    if [[ ! -b $sd_part || ! -b $em_part ]]; then
        log_warn "Partição p$p inexistente em algum dispositivo. Pulando."
        continue
    fi

    md5_sd=$(dd if="$sd_part" bs=4M status=none | md5sum | awk '{print $1}')
    md5_em=$(dd if="$em_part" bs=4M status=none | md5sum | awk '{print $1}')

    if [[ "$md5_sd" == "$md5_em" ]]; then
        log_ok  "p$p  IDÊNTICAS  ($md5_sd)"
    else
        log_err "p$p  DIFERENTES → SD=$md5_sd  eMMC=$md5_em"
        ALL_OK=false
    fi
done

echo "─────────────────────────────────────────────────────────"
if $ALL_OK; then
    log_ok "Todas as partições raw conferem. Pode prosseguir com o clone."
    exit 0
else
    log_err "Há partições raw divergentes. Investigue antes de continuar."
    exit 2
fi
