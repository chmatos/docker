#!/bin/bash
# Script para gerenciar databases PostgreSQL

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CONTAINER_NAME="shared-postgresql"
DB_USER="postgres"

# Função para verificar se o container está rodando
check_container() {
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        echo -e "${RED}❌ Container PostgreSQL não está rodando!${NC}"
        echo -e "${YELLOW}Execute: ./start-postgresql.sh${NC}"
        exit 1
    fi
}

# Função para criar database
create_database() {
    local db_name="$1"
    if [ -z "$db_name" ]; then
        echo -e "${RED}❌ Nome do database é obrigatório${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}🔨 Criando database: $db_name${NC}"
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -c "CREATE DATABASE \"$db_name\";"
    echo -e "${GREEN}✅ Database '$db_name' criado com sucesso!${NC}"
}

# Função para deletar database
drop_database() {
    local db_name="$1"
    if [ -z "$db_name" ]; then
        echo -e "${RED}❌ Nome do database é obrigatório${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚠️  Tem certeza que deseja deletar o database '$db_name'? (y/N)${NC}"
    read -r confirmation
    if [[ $confirmation =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑️  Deletando database: $db_name${NC}"
        docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS \"$db_name\";"
        echo -e "${GREEN}✅ Database '$db_name' deletado com sucesso!${NC}"
    else
        echo -e "${BLUE}ℹ️  Operação cancelada${NC}"
    fi
}

# Função para listar databases
list_databases() {
    echo -e "${YELLOW}📋 Databases disponíveis:${NC}"
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -c "\l"
}

# Função para conectar ao database
connect_database() {
    local db_name="$1"
    if [ -z "$db_name" ]; then
        echo -e "${YELLOW}🔌 Conectando ao PostgreSQL (database padrão)...${NC}"
        docker exec -it "$CONTAINER_NAME" psql -U "$DB_USER"
    else
        echo -e "${YELLOW}🔌 Conectando ao database: $db_name${NC}"
        docker exec -it "$CONTAINER_NAME" psql -U "$DB_USER" -d "$db_name"
    fi
}

# Função para fazer backup
backup_database() {
    local db_name="$1"
    if [ -z "$db_name" ]; then
        echo -e "${RED}❌ Nome do database é obrigatório${NC}"
        exit 1
    fi
    
    local backup_file="/backups/${db_name}_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${YELLOW}💾 Fazendo backup do database: $db_name${NC}"
    docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$db_name" > "postgresql/backups/${db_name}_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${GREEN}✅ Backup salvo em: postgresql/backups/${NC}"
}

# Função para restaurar backup
restore_database() {
    local db_name="$1"
    local backup_file="$2"
    
    if [ -z "$db_name" ] || [ -z "$backup_file" ]; then
        echo -e "${RED}❌ Nome do database e arquivo de backup são obrigatórios${NC}"
        exit 1
    fi
    
    if [ ! -f "postgresql/backups/$backup_file" ]; then
        echo -e "${RED}❌ Arquivo de backup não encontrado: $backup_file${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}📥 Restaurando backup para database: $db_name${NC}"
    docker exec -i "$CONTAINER_NAME" psql -U "$DB_USER" -d "$db_name" < "postgresql/backups/$backup_file"
    echo -e "${GREEN}✅ Backup restaurado com sucesso!${NC}"
}

# Menu de ajuda
show_help() {
    echo -e "${BLUE}🐘 PostgreSQL Database Manager${NC}"
    echo ""
    echo "Uso: $0 [comando] [argumentos]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  create <nome>           - Criar novo database"
    echo "  drop <nome>             - Deletar database"
    echo "  list                    - Listar todos os databases"
    echo "  connect [nome]          - Conectar ao database (ou padrão se não especificado)"
    echo "  backup <nome>           - Fazer backup do database"
    echo "  restore <nome> <arquivo> - Restaurar backup para database"
    echo "  help                    - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 create meu_projeto"
    echo "  $0 list"
    echo "  $0 connect meu_projeto"
    echo "  $0 backup meu_projeto"
    echo "  $0 restore meu_projeto meu_projeto_20231201_120000.sql"
}

# Verificar se container está rodando
check_container

# Processar comandos
case "${1:-help}" in
    "create")
        create_database "$2"
        ;;
    "drop")
        drop_database "$2"
        ;;
    "list")
        list_databases
        ;;
    "connect")
        connect_database "$2"
        ;;
    "backup")
        backup_database "$2"
        ;;
    "restore")
        restore_database "$2" "$3"
        ;;
    "help"|*)
        show_help
        ;;
esac