#!/usr/bin/env bash
# 05-backup-emmc.sh — Gera imagem .img.gz do eMMC inteiro
# Uso: sudo ./05-backup-emmc.sh [destino.img.gz]

source "$(dirname "$0")/00-common.sh"

require_root
require_device "$EMMC_DEVICE"

DEFAULT_OUT="/userdata/firefly-backup-$(date +%Y%m%d-%H%M).img.gz"
OUTPUT="${1:-$DEFAULT_OUT}"

log_info "Origem:  $EMMC_DEVICE"
log_info "Destino: $OUTPUT"
log_warn "Garanta espaço livre suficiente em $(dirname "$OUTPUT")"
confirm "Iniciar backup?"

START=$(date +%s)

log_info "Gerando imagem comprimida (gzip -1, otimizado para velocidade)..."
dd if="$EMMC_DEVICE" bs=4M status=progress | gzip -1 > "$OUTPUT"
sync

END=$(date +%s)
ELAPSED=$((END - START))

SIZE=$(du -h "$OUTPUT" | awk '{print $1}')
MD5=$(md5sum "$OUTPUT" | awk '{print $1}')

# Salva metadados ao lado da imagem
META="${OUTPUT}.meta"
cat > "$META" <<EOF
file:    $(basename "$OUTPUT")
source:  $EMMC_DEVICE
date:    $(date -Iseconds)
size:    $SIZE
md5:     $MD5
elapsed: ${ELAPSED}s
host:    $(hostname)
EOF

log_ok "Backup concluído!"
echo "─────────────────────────────────────────"
cat "$META"
echo "─────────────────────────────────────────"
