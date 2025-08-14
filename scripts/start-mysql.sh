#!/bin/bash
# docker-services/scripts/start-mysql.sh

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MYSQL_DIR="$(dirname "$0")/../mysql"

echo -e "${YELLOW}🐳 Iniciando MySQL compartilhado...${NC}"

# Verificar se Docker está rodando
if ! docker info &> /dev/null; then
    echo -e "${RED}❌ Docker não está rodando. Por favor, inicie o Docker primeiro.${NC}"
    exit 1
fi

# Ir para diretório MySQL
cd "$MYSQL_DIR"

# Verificar se já está rodando
if docker-compose ps mysql | grep -q "Up"; then
    echo -e "${GREEN}✅ MySQL já está rodando!${NC}"
    echo -e "${YELLOW}📊 Status dos containers:${NC}"
    docker-compose ps
    exit 0
fi

# Criar diretórios necessários
mkdir -p backups logs mysql-init

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

# Aguardar MySQL ficar pronto
echo -e "${YELLOW}⏳ Aguardando MySQL ficar pronto...${NC}"
timeout=60
counter=0

while [ $counter -lt $timeout ]; do
    if docker-compose exec -T mysql mysqladmin ping -h localhost --silent; then
        echo -e "${GREEN}✅ MySQL está pronto!${NC}"
        break
    fi
    
    echo -n "."
    sleep 2
    counter=$((counter + 2))
done

if [ $counter -ge $timeout ]; then
    echo -e "${RED}❌ Timeout aguardando MySQL ficar pronto${NC}"
    exit 1
fi

# Mostrar informações úteis
echo -e "${GREEN}🎉 MySQL iniciado com sucesso!${NC}"
echo -e "${YELLOW}📋 Informações de conexão:${NC}"
echo "   Host: localhost"
echo "   Port: 3306"
echo "   Root password: $(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2)"
echo "   phpMyAdmin: http://localhost:8080"
echo ""
echo -e "${YELLOW}📊 Status dos containers:${NC}"
docker-compose ps