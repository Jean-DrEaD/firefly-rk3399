#!/usr/bin/env bash
# 06-list-backups.sh — Lista backups disponíveis no manifest
set -euo pipefail
source "$(dirname "$0")/00-common.sh"

MANIFEST="$(dirname "$0")/../images/backups.json"

if ! command -v jq >/dev/null 2>&1; then
    log_err "jq não instalado. Execute: sudo apt install -y jq"
    exit 1
fi

if [[ ! -f $MANIFEST ]]; then
    log_err "Manifest não encontrado: $MANIFEST"
    exit 1
fi

log_info "📦 Backups disponíveis:"
echo

jq -r '.backups[] |
    "  📅 \(.date)\n     Arquivo:  \(.file)\n     Tamanho:  \(.size_human)\n     MD5:      \(.md5)\n     Host:     \(.host) (\(.os))\n     Notas:    \(.notes)\n"' \
    "$MANIFEST"

log_info "Para baixar: ./07-download-backup.sh <YYYY-MM-DD> [destino]"
