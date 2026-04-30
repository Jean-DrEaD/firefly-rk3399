#!/usr/bin/env bash
# 02-clone-boot.sh — Clona /boot (p4) do SD para o eMMC

source "$(dirname "$0")/00-common.sh"

require_root
require_device "${SD_DEVICE}p4"
require_device "${EMMC_DEVICE}p4"

log_warn "Esta operação SOBRESCREVE ${EMMC_DEVICE}p4 (boot do eMMC)."
log_info "Origem:  ${SD_DEVICE}p4"
log_info "Destino: ${EMMC_DEVICE}p4"
confirm "Confirma o clone da partição /boot?"

log_info "Iniciando clone de /boot (p4)..."
dd if="${SD_DEVICE}p4" of="${EMMC_DEVICE}p4" bs=4M status=progress conv=fsync
sync

log_ok "Clone de /boot concluído."
