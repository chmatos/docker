#!/bin/bash
# Script para restaurar o dump do Soutag

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CONTAINER_NAME="postgres_soutag"
DUMP_FILE="soutag_ch.sql"
DUMP_PATH="/pg_dumps/$DUMP_FILE"

echo -e "${YELLOW}🔄 Restaurando dump do Soutag...${NC}"

# Verificar se o container está rodando
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Container PostgreSQL Soutag não está rodando!${NC}"
    echo -e "${YELLOW}Execute: ./scripts/start-postgres-soutag.sh${NC}"
    exit 1
fi

# Verificar se o arquivo de dump existe
if ! docker exec "$CONTAINER_NAME" test -f "$DUMP_PATH"; then
    echo -e "${RED}❌ Arquivo de dump não encontrado: $DUMP_PATH${NC}"
    echo -e "${YELLOW}Certifique-se de que o arquivo soutag_ch.sql está em postgres_soutag/pg_dumps/${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Informações do restore:${NC}"
echo "   Container: $CONTAINER_NAME"
echo "   Dump file: $DUMP_FILE"
echo "   Path: $DUMP_PATH"
echo ""

# Confirmar operação
echo -e "${YELLOW}⚠️  Este processo irá restaurar o dump completo do Soutag.${NC}"
echo -e "${YELLOW}    Isso pode sobrescrever dados existentes.${NC}"
echo -e "${YELLOW}    Deseja continuar? (y/N)${NC}"
read -r confirmation

if [[ ! $confirmation =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}ℹ️  Operação cancelada${NC}"
    exit 0
fi

echo -e "${YELLOW}🚀 Iniciando restore...${NC}"

# Executar restore do dump
echo -e "${YELLOW}📥 Restaurando dump completo...${NC}"
if docker exec -i "$CONTAINER_NAME" psql -U bruno -d postgres < "postgres_soutag/pg_dumps/$DUMP_FILE"; then
    echo -e "${GREEN}✅ Dump restaurado com sucesso!${NC}"
else
    echo -e "${RED}❌ Erro ao restaurar dump${NC}"
    exit 1
fi

# Verificar databases criados
echo -e "${YELLOW}📋 Databases disponíveis após restore:${NC}"
docker exec "$CONTAINER_NAME" psql -U bruno -c "\l"

echo ""
echo -e "${GREEN}🎉 Restore do Soutag concluído!${NC}"
echo -e "${YELLOW}📋 Informações de acesso:${NC}"
echo "   Host: localhost"
echo "   Port: 5433"
echo "   User: bruno"
echo "   Password: senha123"
echo "   Main Database: testdb"
echo "   pgAdmin: http://localhost:8082"