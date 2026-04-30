#!/usr/bin/env bash
# 00-common.sh — Funções utilitárias compartilhadas

# Cores ANSI
readonly C_RESET='\033[0m'
readonly C_RED='\033[0;31m'
readonly C_GREEN='\033[0;32m'
readonly C_YELLOW='\033[0;33m'
readonly C_BLUE='\033[0;34m'

log_info() { echo -e "${C_BLUE}[INFO]${C_RESET} $*"; }
log_ok()   { echo -e "${C_GREEN}[ OK ]${C_RESET} $*"; }
log_warn() { echo -e "${C_YELLOW}[WARN]${C_RESET} $*" >&2; }
log_err()  { echo -e "${C_RED}[ERR ]${C_RESET} $*" >&2; }

# Verifica se está rodando como root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        log_err "Este script precisa ser executado como root (use sudo)."
        exit 1
    fi
}

# Confirma ação destrutiva
confirm() {
    local prompt="${1:-Tem certeza?}"
    read -rp "$prompt [s/N]: " resp
    [[ ${resp,,} == "s" || ${resp,,} == "sim" ]]
}
