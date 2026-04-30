#!/usr/bin/env bash
# 07-download-backup.sh — Baixa imagem + MD5 do Google Drive e valida
# Uso: ./07-download-backup.sh <YYYY-MM-DD> [destino]

set -euo pipefail
source "$(dirname "$0")/00-common.sh"

DATA="${1:?Uso: $0 <YYYY-MM-DD> [destino]}"
DEST_DIR="${2:-./images}"
MANIFEST="$(dirname "$0")/../images/backups.json"

# ─── Verifica dependências ────────────────────────────────────────
for cmd in jq gdown md5sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_err "$cmd não instalado."
        case $cmd in
            jq)     log_info "Instale: sudo apt install jq" ;;
            gdown)  log_info "Instale: sudo apt install pipx && pipx install gdown" ;;
            md5sum) log_info "Instale: sudo apt install coreutils" ;;
        esac
        exit 1
    fi
done

# ─── Extrai dados do manifest ─────────────────────────────────────
read_field() {
    jq -r --arg d "$DATA" ".backups[] | select(.date==\$d) | .$1 // empty" "$MANIFEST"
}

FILE=$(read_field file)
GDRIVE_ID=$(read_field gdrive_id)
GDRIVE_MD5_ID=$(read_field gdrive_md5_id)
MD5=$(read_field md5)

if [[ -z $FILE ]]; then
    log_err "Backup com data $DATA não encontrado no manifest."
    log_info "Use ./06-list-backups.sh para listar disponíveis."
    exit 1
fi

if [[ -z $GDRIVE_ID ]]; then
    log_err "gdrive_id não configurado para $DATA."
    exit 1
fi

mkdir -p "$DEST_DIR"
OUTPUT="$DEST_DIR/$FILE"
MD5_OUTPUT="$DEST_DIR/$FILE.md5"

# ─── Download da imagem ───────────────────────────────────────────
log_info "📥 Baixando imagem do Google Drive..."
log_info "    Arquivo: $FILE"
log_info "    Destino: $OUTPUT"
echo

if [[ -f $OUTPUT ]]; then
    log_warn "Arquivo já existe: $OUTPUT"
    read -rp "Sobrescrever? [s/N]: " resp
    [[ ${resp,,} == "s" ]] || { log_info "Abortado."; exit 0; }
    rm -f "$OUTPUT"
fi

gdown --id "$GDRIVE_ID" -O "$OUTPUT"

# ─── Download do MD5 (se disponível) ──────────────────────────────
if [[ -n $GDRIVE_MD5_ID ]]; then
    log_info "📥 Baixando arquivo MD5 de referência..."
    gdown --id "$GDRIVE_MD5_ID" -O "$MD5_OUTPUT" --quiet
    REMOTE_MD5=$(awk '{print $1}' "$MD5_OUTPUT" | tr -d '[:space:]' | tr 'A-Z' 'a-z')
    log_info "    MD5 remoto: $REMOTE_MD5"
fi

# ─── Validação ────────────────────────────────────────────────────
log_info "🔐 Calculando MD5 local..."
ACTUAL=$(md5sum "$OUTPUT" | awk '{print $1}')
log_info "    MD5 local:  $ACTUAL"

# Compara: prioriza MD5 baixado; cai pro manifest se não tiver
EXPECTED="${REMOTE_MD5:-$MD5}"

if [[ -z $EXPECTED ]]; then
    log_warn "Nenhum MD5 de referência disponível. Pulando validação."
elif [[ "$ACTUAL" == "$EXPECTED" ]]; then
    log_ok "✅ Integridade verificada! MD5: $ACTUAL"
else
    log_err "❌ MD5 NÃO confere!"
    log_err "   Esperado: $EXPECTED"
    log_err "   Obtido:   $ACTUAL"
    log_err "   Arquivo possivelmente corrompido — refaça o download."
    exit 2
fi

echo
log_ok "🎉 Download concluído!"
log_info "Para restaurar:"
echo "    sudo ./scripts/99-restore-image.sh \"$OUTPUT\" /dev/mmcblkX"
