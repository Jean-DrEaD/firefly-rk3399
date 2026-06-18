#!/usr/bin/env bash
# 05-backup-emmc.sh — Gera imagem .img.gz do eMMC inteiro
# Uso: sudo ./05-backup-emmc.sh [destino.img.gz]

source "$(dirname "$0")/00-common.sh"

require_root
identify_storage
require_device "$EMMC_DEVICE"

DEFAULT_OUT="/userdata/firefly-backup-$(date +%Y%m%d-%H%M).img.gz"
OUTPUT="${1:-$DEFAULT_OUT}"

# Garante que o diretório de destino existe
OUT_DIR=$(dirname "$OUTPUT")
if [[ ! -d "$OUT_DIR" ]]; then
    log_warn "Diretório $OUT_DIR não existe. Criando..."
    mkdir -p "$OUT_DIR" || { log_err "Não foi possível criar $OUT_DIR"; exit 1; }
fi

log_info "Origem:  $EMMC_DEVICE"
log_info "Destino: $OUTPUT"
log_warn "Garanta espaço livre suficiente em $OUT_DIR"
confirm "Iniciar backup?"

START=$(date +%s)

log_info "Gerando imagem comprimida (gzip -1, otimizado para velocidade)..."
dd if="$EMMC_DEVICE" bs=4M status=progress | gzip -1 > "$OUTPUT"
sync

END=$(date +%s)
ELAPSED=$((END - START))

SIZE=$(du -h "$OUTPUT" | awk '{print $1}')
SIZE_BYTES=$(du -b "$OUTPUT" | awk '{print $1}')
MD5=$(md5sum "$OUTPUT" | awk '{print $1}')

# Arquivo .md5 separado (para validação e upload no Drive)
MD5_FILE="${OUTPUT}.md5"
echo "$MD5  $(basename "$OUTPUT")" > "$MD5_FILE"

# Salva metadados ao lado da imagem
META="${OUTPUT}.meta"
cat > "$META" <<EOF
file:       $(basename "$OUTPUT")
source:     $EMMC_DEVICE
date:       $(date -Iseconds)
size:       $SIZE
size_bytes: $SIZE_BYTES
md5:        $MD5
elapsed:    ${ELAPSED}s
host:       $(hostname)
EOF

log_ok "Backup concluído!"
echo "─────────────────────────────────────────"
cat "$META"
echo "─────────────────────────────────────────"
log_info "Arquivo .md5: $MD5_FILE"
log_info "Próximo passo: faça upload de $OUTPUT e $MD5_FILE para o Google Drive"
log_info "Depois atualize images/backups.json com os IDs e metadados acima."
