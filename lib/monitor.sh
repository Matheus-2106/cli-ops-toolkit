#!/usr/bin/env bash

# ==============================================================================
# Módulo: monitor.sh
# Descrição: Funções de extração de métricas de hardware e saúde do sistema.
# ==============================================================================

# Função para analisar o uso da memória RAM
check_memory() {
    log_info "Coletando dados de uso de memória RAM..."
    
    # Extrai os dados ignorando o cabeçalho do free (pega a segunda linha útil)
    local total_mem used_mem free_mem percent_used
    read -r total_mem used_mem free_mem < <(free -m | awk 'NR==2{print $2, $3, $4}')
    
    # Validação para evitar divisão por zero caso a leitura falhe
    if [[ -z "$total_mem" || "$total_mem" -eq 0 ]]; then
        log_error "Não foi possível determinar a memória total do sistema."
        return 1
    fi

    percent_used=$(( (used_mem * 100) / total_mem ))

    echo -e "  • Total: ${total_mem} MB | Usada: ${used_mem} MB (${percent_used}%) | Livre: ${free_mem} MB"

    if [[ "$percent_used" -gt 85 ]]; then
        log_warn "Uso de memória elevado: ${percent_used}% em uso!"
    else
        log_success "Uso de memória dentro dos limites operacionais."
    fi
}

# Função para analisar o consumo da partição principal (/)
check_disk() {
    log_info "Coletando dados da partição principal (/)..."
    
    local disk_usage
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    echo -e "  • Espaço ocupado na partição /: ${disk_usage}%"

    if [[ "$disk_usage" -gt 80 ]]; then
        log_warn "Espaço em disco crítico: ${disk_usage}% preenchido!"
    else
        log_success "Espaço em disco saudável."
    fi
}

# Função para verificar o Load Average e Top Processos
check_cpu_and_processes() {
    log_info "Verificando carga do sistema (Load Average)..."
    local uptime_info
    uptime_info=$(uptime | awk -F'load average:' '{ print $2 }')
    echo -e "  • Load Average (1m, 5m, 15m):${uptime_info}"

    echo ""
    log_info "Top 5 processos por consumo de memória:"
    ps aux --sort=-%mem | awk 'NR==1 || NR<=6 {printf "  %-10s %-8s %-6s %-6s %s\n", $1, $2, $3, $4, $11}'
}

# Função consolidada de diagnósticos
run_system_diagnostics() {
    echo -e "\n=========================================="
    echo -e "     RELATÓRIO DE DIAGNÓSTICO DO SISTEMA"
    echo -e "==========================================\n"
    
    check_memory
    echo ""
    check_disk
    echo ""
    check_cpu_and_processes
    echo -e "\n==========================================\n"
}