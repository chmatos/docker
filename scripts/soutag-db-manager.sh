#!/bin/bash
# Script para gerenciar PostgreSQL Soutag

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CONTAINER_NAME="postgres_soutag"
DB_USER="bruno"

# Função para verificar se o container está rodando
check_container() {
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        echo -e "${RED}❌ Container PostgreSQL Soutag não está rodando!${NC}"
        echo -e "${YELLOW}Execute: ./scripts/start-postgres-soutag.sh${NC}"
        exit 1
    fi
}

# Função para listar databases
list_databases() {
    echo -e "${YELLOW}📋 Databases disponíveis no Soutag:${NC}"
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -c "\l"
}

# Função para conectar ao database
connect_database() {
    local db_name="$1"
    if [ -z "$db_name" ]; then
        echo -e "${YELLOW}🔌 Conectando ao PostgreSQL Soutag (database padrão: testdb)...${NC}"
        docker exec -it "$CONTAINER_NAME" psql -U "$DB_USER" -d testdb
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
    
    local backup_file="${db_name}_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${YELLOW}💾 Fazendo backup do database: $db_name${NC}"
    docker exec "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$db_name" > "postgres_soutag/backups/$backup_file"
    echo -e "${GREEN}✅ Backup salvo em: postgres_soutag/backups/$backup_file${NC}"
}

# Função para backup completo (cluster)
backup_cluster() {
    local backup_file="soutag_cluster_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${YELLOW}💾 Fazendo backup completo do cluster Soutag...${NC}"
    docker exec "$CONTAINER_NAME" pg_dumpall -U "$DB_USER" > "postgres_soutag/backups/$backup_file"
    echo -e "${GREEN}✅ Backup completo salvo em: postgres_soutag/backups/$backup_file${NC}"
}

# Função para verificar PostGIS
check_postgis() {
    echo -e "${YELLOW}🗺️  Verificando PostGIS...${NC}"
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d testdb -c "SELECT PostGIS_Version();"
    echo ""
    echo -e "${YELLOW}📋 Extensions PostGIS disponíveis:${NC}"
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d testdb -c "SELECT name, default_version, installed_version FROM pg_available_extensions WHERE name LIKE '%postgis%';"
}

# Função para executar SQL
execute_sql() {
    local sql_command="$1"
    local db_name="${2:-testdb}"
    
    if [ -z "$sql_command" ]; then
        echo -e "${RED}❌ Comando SQL é obrigatório${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}⚡ Executando SQL no database: $db_name${NC}"
    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$db_name" -c "$sql_command"
}

# Menu de ajuda
show_help() {
    echo -e "${BLUE}🐘 PostgreSQL Soutag Manager (PostGIS)${NC}"
    echo ""
    echo "Uso: $0 [comando] [argumentos]"
    echo ""
    echo "Comandos disponíveis:"
    echo "  list                    - Listar todos os databases"
    echo "  connect [nome]          - Conectar ao database (padrão: testdb)"
    echo "  backup <nome>           - Fazer backup do database"
    echo "  backup-cluster          - Fazer backup completo do cluster"
    echo "  postgis                 - Verificar status do PostGIS"
    echo "  sql \"<comando>\" [db]    - Executar comando SQL"
    echo "  help                    - Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0 list"
    echo "  $0 connect testdb"
    echo "  $0 backup testdb"
    echo "  $0 backup-cluster"
    echo "  $0 postgis"
    echo "  $0 sql \"SELECT version();\" testdb"
    echo ""
    echo "Informações de conexão:"
    echo "  Host: localhost:5433"
    echo "  User: bruno"
    echo "  Password: senha123"
    echo "  pgAdmin: http://localhost:8082"
}

# Verificar se container está rodando
check_container

# Processar comandos
case "${1:-help}" in
    "list")
        list_databases
        ;;
    "connect")
        connect_database "$2"
        ;;
    "backup")
        backup_database "$2"
        ;;
    "backup-cluster")
        backup_cluster
        ;;
    "postgis")
        check_postgis
        ;;
    "sql")
        execute_sql "$2" "$3"
        ;;
    "help"|*)
        show_help
        ;;
esac