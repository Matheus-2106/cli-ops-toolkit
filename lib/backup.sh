#!/usr/bin/env bash

# ==============================================================================
# Módulo: backup.sh
# Descrição: Automação de backup compactado (.tar.gz) com rotação configurável.
# ==============================================================================

# Carregar variáveis do arquivo de configuração (ou usar valores padrão)
load_backup_config() {
    local conf_file="${SCRIPT_DIR}/config/sysops.conf"
    
    if [[ -f "$conf_file" ]]; then
        source "$conf_file"
    else
        log_warn "Arquivo 'config/sysops.conf' não encontrado. Usando valores padrão do ambiente."
        BACKUP_SOURCE_DIR="${BACKUP_SOURCE_DIR:-$HOME/Documentos}"
        BACKUP_DEST_DIR="${BACKUP_DEST_DIR:-$HOME/backups_sysops}"
        MAX_BACKUPS="${MAX_BACKUPS:-3}"
        LOG_FILE="${LOG_FILE:-$BACKUP_DEST_DIR/backup.log}"
    fi
}

# Realizar o backup compactado
run_backup() {
    load_backup_config

    log_info "Iniciando rotina de backup..."
    
    if [[ ! -d "$BACKUP_SOURCE_DIR" ]]; then
        log_error "Diretório de origem não existe: $BACKUP_SOURCE_DIR"
        return 1
    fi

    # Criar pasta de destino se não existir
    mkdir -p "$BACKUP_DEST_DIR"

    # Definir nome do arquivo com timestamp
    local timestamp
    timestamp=$(date +'%Y%m%d_%H%M%S')
    local backup_filename="backup_${timestamp}.tar.gz"
    local backup_filepath="${BACKUP_DEST_DIR}/${backup_filename}"

    log_info "Origem: $BACKUP_SOURCE_DIR"
    log_info "Destino: $backup_filepath"

    # Compactar
    if tar -czf "$backup_filepath" -C "$(dirname "$BACKUP_SOURCE_DIR")" "$(basename "$BACKUP_SOURCE_DIR")" 2>/dev/null; then
        log_success "Backup criado com sucesso: $backup_filename"
        echo "$(date +'%Y-%m-%d %H:%M:%S') - SUCCESS - $backup_filename" >> "$LOG_FILE"
        
        # Executar rotação
        rotate_backups
    else
        log_error "Falha ao criar o arquivo de backup."
        echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR - Falha ao compactar $BACKUP_SOURCE_DIR" >> "$LOG_FILE"
        return 1
    fi
}

# Rotação de backups antigos para não lotar o disco
rotate_backups() {
    log_info "Verificando política de retenção (Máximo: $MAX_BACKUPS backups)..."

    local current_count
    current_count=$(ls -1t "${BACKUP_DEST_DIR}"/backup_*.tar.gz 2>/dev/null | wc -l)

    if [[ "$current_count" -gt "$MAX_BACKUPS" ]]; then
        local backups_to_remove
        backups_to_remove=$(ls -1t "${BACKUP_DEST_DIR}"/backup_*.tar.gz | tail -n +"$((MAX_BACKUPS + 1))")

        for file in $backups_to_remove; do
            log_warn "Removendo backup antigo devido à retenção: $(basename "$file")"
            rm -f "$file"
            echo "$(date +'%Y-%m-%d %H:%M:%S') - ROTATE - Removido: $(basename "$file")" >> "$LOG_FILE"
        done
    else
        log_success "Número de backups ($current_count) dentro do limite definido ($MAX_BACKUPS)."
    fi
}