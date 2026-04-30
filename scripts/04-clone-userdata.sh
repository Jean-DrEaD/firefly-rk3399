#!/usr/bin/env bash
# 04-clone-userdata.sh — Clona userdata (p8) do SD para o eMMC

source "$(dirname "$0")/00-common.sh"

require_root
require_device "${SD_DEVICE}p8"
require_device "${EMMC_DEVICE}p8"

log_warn "Esta operação SOBRESCREVE ${EMMC_DEVICE}p8 (userdata do eMMC)."
log_info "Origem:  ${SD_DEVICE}p8"
log_info "Destino: ${EMMC_DEVICE}p8"
confirm "Confirma o clone de userdata?"

log_info "Iniciando clone de userdata (p8)..."
dd if="${SD_DEVICE}p8" of="${EMMC_DEVICE}p8" bs=4M status=progress conv=fsync
sync

log_ok "Clone de userdata concluído."
