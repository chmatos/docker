#!/bin/bash
# docker-services/scripts/start-postgres-soutag.sh

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

POSTGRES_DIR="$(dirname "$0")/../postgres_soutag"

echo -e "${YELLOW}🐳 Iniciando PostgreSQL Soutag (PostGIS)...${NC}"

# Verificar se Docker está rodando
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker não está rodando. Por favor, inicie o Docker primeiro.${NC}"
    exit 1
fi

# Ir para diretório PostgreSQL Soutag
cd "$POSTGRES_DIR"

# Verificar se já está rodando
if docker-compose ps postgres | grep -q "Up"; then
    echo -e "${GREEN}✅ PostgreSQL Soutag já está rodando!${NC}"
    echo -e "${YELLOW}📊 Status dos containers:${NC}"
    docker-compose ps
    exit 0
fi

# Criar diretórios necessários
mkdir -p pg_dumps backups logs postgres-init

# Verificar se arquivo .env existe
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${YELLOW}⚠️  Arquivo .env criado a partir do .env.example${NC}"
        echo -e "${YELLOW}    Por favor, revise as configurações em .env${NC}"
    else
        echo -e "${RED}❌ Arquivo .env não encontrado!${NC}"
        exit 1
    fi
fi

# Iniciar containers
echo -e "${YELLOW}🚀 Iniciando containers...${NC}"
docker-compose up -d

# Aguardar PostgreSQL ficar pronto
echo -e "${YELLOW}⏳ Aguardando PostgreSQL Soutag ficar pronto...${NC}"
timeout=60
counter=0

while [ $counter -lt $timeout ]; do
    if docker-compose exec -T postgres pg_isready -U bruno; then
        echo -e "${GREEN}✅ PostgreSQL Soutag está pronto!${NC}"
        break
    fi
    
    echo -n "."
    sleep 2
    counter=$((counter + 2))
done

if [ $counter -ge $timeout ]; then
    echo -e "${RED}❌ Timeout aguardando PostgreSQL Soutag ficar pronto${NC}"
    exit 1
fi

# Mostrar informações úteis
echo -e "${GREEN}🎉 PostgreSQL Soutag iniciado com sucesso!${NC}"
echo -e "${YELLOW}📋 Informações de conexão:${NC}"
echo "   Host: localhost"
echo "   Port: 5433"
echo "   User: $(grep POSTGRES_USER .env | cut -d'=' -f2)"
echo "   Password: $(grep POSTGRES_PASSWORD .env | cut -d'=' -f2)"
echo "   Database: $(grep POSTGRES_DB .env | cut -d'=' -f2)"
echo "   pgAdmin: http://localhost:8082"
echo ""
echo -e "${YELLOW}🗺️  PostGIS Extensions disponíveis${NC}"
echo ""
echo -e "${YELLOW}📊 Status dos containers:${NC}"
docker-compose ps