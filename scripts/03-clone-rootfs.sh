#!/usr/bin/env bash
# 03-clone-rootfs.sh — Clona rootfs (p7) do SD para o eMMC

source "$(dirname "$0")/00-common.sh"

require_root
require_device "${SD_DEVICE}p7"
require_device "${EMMC_DEVICE}p7"

log_warn "Esta operação SOBRESCREVE ${EMMC_DEVICE}p7 (rootfs do eMMC)."
log_info "Origem:  ${SD_DEVICE}p7"
log_info "Destino: ${EMMC_DEVICE}p7"
log_warn "Recomenda-se parar serviços críticos antes (klipper, moonraker)."
confirm "Confirma o clone do rootfs?"

# Para serviços críticos para garantir consistência
log_info "Parando serviços críticos..."
for svc in klipper moonraker klipperscreen; do
    systemctl stop "$svc" 2>/dev/null || true
done

log_info "Iniciando clone do rootfs (p7) — pode levar vários minutos..."
dd if="${SD_DEVICE}p7" of="${EMMC_DEVICE}p7" bs=4M status=progress conv=fsync
sync

log_ok "Clone do rootfs concluído."
log_info "Reinicie os serviços ou faça reboot para validar."
