#!/usr/bin/env bash
# 99-restore-image.sh — Restaura uma imagem .img.gz para um device
# Uso: sudo ./99-restore-image.sh <imagem.img.gz> <device>
# Ex.:  sudo ./99-restore-image.sh firefly-backup.img.gz /dev/mmcblk0

source "$(dirname "$0")/00-common.sh"

require_root

if [[ $# -ne 2 ]]; then
    log_err "Uso: $0 <imagem.img.gz> <device>"
    log_err "Ex.: $0 firefly-backup.img.gz /dev/mmcblk0"
    exit 1
fi

IMAGE=$1
TARGET=$2

[[ -f $IMAGE ]] || { log_err "Imagem não encontrada: $IMAGE"; exit 1; }
require_device "$TARGET"

log_warn "═══════════════════════════════════════════════════════════"
log_warn " ATENÇÃO: Esta operação APAGA TODOS OS DADOS de $TARGET"
log_warn "═══════════════════════════════════════════════════════════"
log_info "Imagem:  $IMAGE"
log_info "Destino: $TARGET ($(lsblk -ndo SIZE "$TARGET"))"
echo
lsblk "$TARGET"
echo
confirm "Tem CERTEZA que deseja restaurar?"
confirm "Última chance — confirmar novamente?"

log_info "Restaurando imagem..."
gunzip -c "$IMAGE" | dd of="$TARGET" bs=4M status=progress conv=fsync
sync

log_ok "Restauração concluída!"
log_info "Execute 'sudo partprobe $TARGET' e reinicie."
