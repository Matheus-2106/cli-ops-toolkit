#!/usr/bin/env bash

# ==============================================================================
# Módulo: utils.sh
# Descrição: Funções de suporte para formatação de texto, logs e diagnósticos.
# ==============================================================================

# Cores para output no terminal
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color / Reset

# Função para exibir mensagens informativas
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Função para exibir mensagens de sucesso
log_success() {
    echo -e "${GREEN}[OK]${NC} $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Função para exibir avisos
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Função para exibir erros
log_error() {
    echo -e "${RED}[ERROR]${NC} $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Função para validar se uma ferramenta/comando existe no sistema
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Comando necessário '$cmd' não está instalado."
        return 1
    fi
}