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

# Verifica se um dispositivo de bloco existe
# Uso: require_device /dev/mmcblk0
require_device() {
    local dev="$1"
    if [[ -z "$dev" ]]; then
        log_err "Dispositivo não especificado. Verifique SD_DEVICE/EMMC_DEVICE ou rode identify_storage primeiro."
        exit 1
    fi
    # Para partições (ex: /dev/mmcblk0p4), verifica o dispositivo pai
    local base
    base=$(echo "$dev" | sed 's/p[0-9]*$//')
    if [[ ! -b "$base" ]]; then
        log_err "Dispositivo de bloco não encontrado: $base"
        exit 1
    fi
}

# Auto-detecta SD (/dev/mmcblk1) e eMMC (/dev/mmcblk0) no Firefly RK3399.
# No BSP Rockchip: mmcblk0 = eMMC (boot), mmcblk1 = SD card.
# Exporta: SD_DEVICE, EMMC_DEVICE
identify_storage() {
    # Permite override via variáveis de ambiente
    if [[ -n "$SD_DEVICE" && -n "$EMMC_DEVICE" ]]; then
        log_info "Usando dispositivos definidos manualmente: SD=$SD_DEVICE  eMMC=$EMMC_DEVICE"
        return 0
    fi

    # No BSP Firefly/Rockchip RK3399: mmcblk0 = eMMC, mmcblk1 = SD
    local candidate_emmc="/dev/mmcblk0"
    local candidate_sd="/dev/mmcblk1"

    # Validação: confirma via /sys que mmcblk0 é eMMC
    local type0
    type0=$(cat /sys/block/mmcblk0/device/type 2>/dev/null || echo "")
    local type1
    type1=$(cat /sys/block/mmcblk1/device/type 2>/dev/null || echo "")

    # type "MMC" = eMMC, type "SD" = SD card
    if [[ "$type0" == "MMC" && "$type1" == "SD" ]]; then
        EMMC_DEVICE="$candidate_emmc"
        SD_DEVICE="$candidate_sd"
    elif [[ "$type0" == "SD" && "$type1" == "MMC" ]]; then
        # Invertido — incomum mas possível
        SD_DEVICE="$candidate_emmc"
        EMMC_DEVICE="$candidate_sd"
        log_warn "Detecção invertida: mmcblk0=SD, mmcblk1=eMMC. Confirme se está correto."
    elif [[ -b "$candidate_emmc" && ! -b "$candidate_sd" ]]; then
        # Só eMMC presente (rodando direto da eMMC, sem SD)
        EMMC_DEVICE="$candidate_emmc"
        SD_DEVICE=""
        log_warn "SD não detectado. Operações de clone não estarão disponíveis."
    else
        log_err "Não foi possível detectar SD/eMMC automaticamente."
        log_err "Defina manualmente: export SD_DEVICE=/dev/mmcblkX EMMC_DEVICE=/dev/mmcblkY"
        exit 1
    fi

    export SD_DEVICE EMMC_DEVICE
    log_info "SD detectado:   ${SD_DEVICE:-N/A}"
    log_info "eMMC detectado: ${EMMC_DEVICE:-N/A}"
}

# Confirma ação destrutiva
confirm() {
    local prompt="${1:-Tem certeza?}"
    read -rp "$prompt [s/N]: " resp
    [[ ${resp,,} == "s" || ${resp,,} == "sim" ]]
}
