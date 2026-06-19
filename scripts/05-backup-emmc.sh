#!/usr/bin/env bash
# 05-backup-emmc.sh — Gera imagem .img.gz do eMMC inteiro
# Uso: sudo ./05-backup-emmc.sh [destino.img.gz]

source "$(dirname "$0")/00-common.sh"

require_root
identify_storage
require_device "$EMMC_DEVICE"

# ── Garante SD particionado/formatado/montado ──────────────────────────────
# Só mexe no SD se o destino não foi passado explicitamente como argumento
# (se o usuário já informou um caminho, ele sabe o que está fazendo).
if [[ -z "${1:-}" && -n "$SD_DEVICE" ]]; then
    ensure_sd_mounted "$SD_DEVICE" || log_warn "Prosseguindo sem SD; backup será salvo localmente."
fi

# ── Detecta destino padrão: ponto de montagem do SD (ou home como fallback) ──
# IMPORTANTE: esta função é "pura" (sem logs/efeitos colaterais), pois sua
# saída é capturada via $(...). Toda a lógica de montagem já rodou acima.
_default_output() {
    local fname="firefly-backup-$(date +%Y%m%d-%H%M).img.gz"

    if [[ -n "${SD_MOUNTPOINT:-}" ]]; then
        echo "${SD_MOUNTPOINT}/${fname}"
        return
    fi

    local real_home
    real_home=$(getent passwd "${SUDO_USER:-pi}" | cut -d: -f6 2>/dev/null || echo "/home/pi")
    echo "${real_home}/${fname}"
}

if [[ -z "${1:-}" && -z "${SD_MOUNTPOINT:-}" ]]; then
    log_warn "SD não disponível como destino. Usando diretório home como fallback."
    log_warn "Certifique-se de ter espaço suficiente."
fi

DEFAULT_OUT="$(_default_output)"
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

BASENAME=$(basename "$OUTPUT")
DATE_STR=$(date +%Y-%m-%d)
SIZE=$(du -h "$OUTPUT" | awk '{print $1}')
SIZE_BYTES=$(du -b "$OUTPUT" | awk '{print $1}')
MD5=$(md5sum "$OUTPUT" | awk '{print $1}')
OS_STR=$(lsb_release -ds 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d'"' -f2 || echo "Ubuntu aarch64")
KERNEL_STR=$(uname -r)

# Arquivo .md5 separado (para validação e upload no Drive)
MD5_FILE="${OUTPUT}.md5"
echo "$MD5  $BASENAME" > "$MD5_FILE"

# Salva metadados ao lado da imagem
META="${OUTPUT}.meta"
cat > "$META" <<EOF
file:       $BASENAME
source:     $EMMC_DEVICE
date:       $(date -Iseconds)
size:       $SIZE
size_bytes: $SIZE_BYTES
md5:        $MD5
elapsed:    ${ELAPSED}s
host:       $(hostname)
os:         $OS_STR
kernel:     $KERNEL_STR
EOF

log_ok "Backup concluído!"
echo "─────────────────────────────────────────"
cat "$META"
echo "─────────────────────────────────────────"
log_info "Arquivo .md5: $MD5_FILE"

# ── Snippet pronto para colar no backups.json ──────────────────────────────────
echo ""
log_info "Faça upload de $BASENAME e $BASENAME.md5 no Google Drive e anote os IDs."
log_info "Depois cole o bloco abaixo como PRIMEIRO item em images/backups.json:"
echo ""
cat <<JSON
    {
      "date": "$DATE_STR",
      "file": "$BASENAME",
      "md5_file": "${BASENAME}.md5",
      "size_human": "$SIZE",
      "size_bytes": $SIZE_BYTES,
      "md5": "$MD5",
      "gdrive_id": "PREENCHER",
      "gdrive_md5_id": "PREENCHER",
      "host": "firefly ($(hostname))",
      "os": "$OS_STR",
      "kernel": "$KERNEL_STR",
      "notes": "boot corrigido, eddy-ng + Kalico atualizados"
    },
JSON

echo ""
log_info "Próximos passos:"
echo "  1. Upload de $BASENAME e ${BASENAME}.md5 no Google Drive"
echo "  2. Compartilhar ambos como 'Qualquer pessoa com o link' (Leitor)"
echo "  3. Anotar os dois IDs (formato: 1AbCdEf...)"
echo "  4. Substituir os campos PREENCHER no JSON acima"
echo "  5. Colar como primeiro item em images/backups.json"
echo "  6. git add images/backups.json README.md RELEASE_NOTES_v${DATE_STR//-/}.md"
echo "  7. git commit -m 'manifest: adiciona backup $DATE_STR'"
echo "  8. Executar apply-release.ps1 no Windows para tag + GitHub Release"
