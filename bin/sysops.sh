#!/usr/bin/env bash

# ==============================================================================
# Script: sysops.sh
# Descrição: Entrypoint da CLI-Ops Toolkit.
# ==============================================================================

# Resolução do diretório raiz do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Carregar bibliotecas
if [[ -f "${SCRIPT_DIR}/lib/utils.sh" ]]; then
    source "${SCRIPT_DIR}/lib/utils.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Não foi possível carregar lib/utils.sh"
    exit 1
fi

if [[ -f "${SCRIPT_DIR}/lib/monitor.sh" ]]; then
    source "${SCRIPT_DIR}/lib/monitor.sh"
else
    log_error "Não foi possível carregar lib/monitor.sh"
    exit 1
fi

# Exibir menu de ajuda
show_help() {
    cat << EOF
CLI-Ops Toolkit - Automação e Diagnóstico de Sistemas Linux

Uso: $(basename "$0") [OPÇÃO]

Opções:
  -h, --help        Exibe esta mensagem de ajuda
  -v, --version     Exibe a versão do toolkit
  -c, --check       Executa validação dos pré-requisitos do ambiente
  -m, --monitor     Executa o relatório completo de monitorização do sistema

Exemplo:
  $ ./bin/sysops.sh --monitor
EOF
}

# Função para verificar o ambiente
check_environment() {
    log_info "Verificando dependências do sistema..."
    local dependencies=("tar" "df" "free" "ps" "awk" "bash")
    local missing=0

    for cmd in "${dependencies[@]}"; do
        if check_command "$cmd"; then
            log_success "Dependência '$cmd' encontrada."
        else
            missing=$((missing + 1))
        fi
    done

    if [[ $missing -eq 0 ]]; then
        log_success "Ambiente verificado com sucesso! Todas as dependências estão presentes."
    else
        log_warn "Existem $missing dependências ausentes no sistema."
    fi
}

# Processamento de argumentos da linha de comando
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi

    case "$1" in
        -h|--help)
            show_help
            ;;
        -v|--version)
            echo "CLI-Ops Toolkit v0.2.0"
            ;;
        -c|--check)
            check_environment
            ;;
        -m|--monitor)
            run_system_diagnostics
            ;;
        *)
            log_error "Opção inválida: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"