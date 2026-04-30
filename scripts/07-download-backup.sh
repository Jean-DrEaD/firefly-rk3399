#!/usr/bin/env bash
# 07-download-backup.sh — baixa imagem de backup do Google Drive
# Uso: ./07-download-backup.sh <YYYY-MM-DD> [destino]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=00-common.sh
source "${SCRIPT_DIR}/00-common.sh"

MANIFEST="${SCRIPT_DIR}/../images/backups.json"
DATE="${1:-}"
DEST="${2:-$(pwd)}"

if [[ -z "$DATE" ]]; then
  log_err "Uso: $0 <YYYY-MM-DD> [destino]"
  log_info "Backups disponíveis:"
  "${SCRIPT_DIR}/06-list-backups.sh"
  exit 1
fi

# Dependências
command -v jq    >/dev/null || { log_err "jq não encontrado. Instale: sudo apt install jq"; exit 1; }
command -v gdown >/dev/null || { log_err "gdown não encontrado. Instale: pipx install gdown"; exit 1; }
command -v md5sum >/dev/null || { log_err "md5sum não encontrado."; exit 1; }

[[ -f "$MANIFEST" ]] || { log_err "Manifest não encontrado: $MANIFEST"; exit 1; }

# Lê metadados do manifest
ENTRY=$(jq -r --arg d "$DATE" '.backups[] | select(.date==$d)' "$MANIFEST")
if [[ -z "$ENTRY" ]]; then
  log_err "Backup com data '$DATE' não encontrado no manifest."
  "${SCRIPT_DIR}/06-list-backups.sh"
  exit 1
fi

FILE=$(echo "$ENTRY"      | jq -r '.file')
MD5_FILE=$(echo "$ENTRY"  | jq -r '.md5_file')
MD5_EXPECT=$(echo "$ENTRY"| jq -r '.md5')
GID=$(echo "$ENTRY"       | jq -r '.gdrive_id')
GID_MD5=$(echo "$ENTRY"   | jq -r '.gdrive_md5_id')

mkdir -p "$DEST"
cd "$DEST"

log_info "📥 Baixando imagem do Google Drive..."
log_info "    Arquivo: $FILE"
log_info "    Destino: $DEST/$FILE"

# gdown >= 5.x: passa o ID direto OU usa --fuzzy com URL
gdown --fuzzy "https://drive.google.com/uc?id=${GID}" -O "$FILE"

log_info "📥 Baixando arquivo .md5..."
gdown --fuzzy "https://drive.google.com/uc?id=${GID_MD5}" -O "$MD5_FILE"

# Validação 1: MD5 do manifest vs arquivo baixado
log_info "🔍 Validando MD5 (manifest)..."
MD5_REAL=$(md5sum "$FILE" | awk '{print $1}')
if [[ "$MD5_REAL" != "$MD5_EXPECT" ]]; then
  log_err "❌ MD5 não confere com manifest!"
  log_err "    Esperado: $MD5_EXPECT"
  log_err "    Obtido:   $MD5_REAL"
  exit 2
fi
log_info "✅ MD5 manifest OK: $MD5_REAL"

# Validação 2: arquivo .md5 baixado vs arquivo real
log_info "🔍 Validando MD5 (arquivo .md5)..."
if md5sum -c "$MD5_FILE" >/dev/null 2>&1; then
  log_info "✅ MD5 file OK"
else
  log_warn "⚠️  Arquivo .md5 não bateu (pode ter formato diferente). MD5 do manifest já validou."
fi

log_info "🎉 Download concluído com sucesso!"
log_info "    $DEST/$FILE"
log_info ""
log_info "Para restaurar:"
log_info "    sudo ./scripts/99-restore-image.sh $DEST/$FILE /dev/mmcblkX"