#!/bin/bash
# mysql-upgrade.sh - Upgrade MySQL 8.0 → 9.0

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
NC='\033[0m'

DOCKER_COMPOSE_DIR="$HOME/projetos/docker/mysql"

echo -e "${YELLOW}🔄 Upgrade MySQL 8.0 → 9.0${NC}"

cd "$DOCKER_COMPOSE_DIR"

# 1. Parar containers
echo -e "${YELLOW}🛑 Parando containers...${NC}"
docker-compose down

# 2. Fazer backup dos dados atuais
echo -e "${YELLOW}💾 Fazendo backup dos dados atuais...${NC}"
BACKUP_NAME="mysql_backup_before_upgrade_$(date +%Y%m%d_%H%M%S)"
docker run --rm \
    -v shared_mysql_data:/source \
    -v "$HOME/$BACKUP_NAME":/backup \
    alpine sh -c "cp -r /source /backup"

# 3. Iniciar MySQL 8.0 temporário para export
echo -e "${YELLOW}📤 Iniciando MySQL 8.0 para export...${NC}"
cat > docker-compose.temp.yml << 'EOF'
version: '3.8'
services:
  mysql-temp:
    image: mysql:8.0
    platform: linux/amd64
    container_name: mysql-upgrade-temp
    environment:
      MYSQL_ROOT_PASSWORD: password
    volumes:
      - shared_mysql_data:/var/lib/mysql
    ports:
      - "3307:3306"
    networks:
      - shared-network
networks:
  shared-network:
    driver: bridge
volumes:
  shared_mysql_data:
    external: true
EOF

docker-compose -f docker-compose.temp.yml up -d mysql-temp

# Aguardar MySQL 8.0 ficar pronto
echo -e "${YELLOW}⏳ Aguardando MySQL 8.0...${NC}"
timeout=60
counter=0
while [ $counter -lt $timeout ]; do
    if docker exec mysql-upgrade-temp mysqladmin ping -h localhost --silent 2>/dev/null; then
        break
    fi
    sleep 2
    counter=$((counter + 2))
done

# 4. Fazer dump completo
echo -e "${YELLOW}📋 Exportando todos os dados...${NC}"
docker exec mysql-upgrade-temp mysqldump \
    -u root -ppassword \
    --all-databases \
    --single-transaction \
    --routines \
    --triggers \
    --add-drop-database \
    --disable-keys \
    --extended-insert \
    --quick \
    --lock-tables=false > "$HOME/mysql_full_dump_$(date +%Y%m%d_%H%M%S).sql"

# 5. Parar MySQL 8.0
echo -e "${YELLOW}🛑 Parando MySQL 8.0...${NC}"
docker-compose -f docker-compose.temp.yml down
rm docker-compose.temp.yml

# 6. Limpar dados antigos
echo -e "${YELLOW}🗑️ Limpando dados antigos...${NC}"
docker run --rm -v shared_mysql_data:/target alpine rm -rf /target/*

# 7. Alterar docker-compose.yml para MySQL 9.0
echo -e "${YELLOW}📝 Atualizando configuração para MySQL 9.0...${NC}"
sed -i '' 's/mysql:8.0/mysql:9.0/' docker-compose.yml

# 8. Iniciar MySQL 9.0
echo -e "${YELLOW}🚀 Iniciando MySQL 9.0...${NC}"
docker-compose up -d mysql

# Aguardar MySQL 9.0 ficar pronto
echo -e "${YELLOW}⏳ Aguardando MySQL 9.0...${NC}"
timeout=90
counter=0
while [ $counter -lt $timeout ]; do
    if docker-compose exec -T mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
        break
    fi
    sleep 3
    counter=$((counter + 3))
done

# 9. Restaurar dados no MySQL 9.0
echo -e "${YELLOW}📥 Importando dados no MySQL 9.0...${NC}"
DUMP_FILE="$(ls -t $HOME/mysql_full_dump_*.sql | head -n1)"
docker exec -i shared-mysql mysql -u root -ppassword < "$DUMP_FILE"

echo -e "${GREEN}✅ Upgrade concluído!${NC}"
echo -e "${YELLOW}📋 Arquivos de backup criados:${NC}"
echo "- Dados: $HOME/$BACKUP_NAME"
echo "- Dump SQL: $DUMP_FILE"

# 10. Verificar resultado
echo -e "${YELLOW}🔍 Verificando databases...${NC}"
docker exec shared-mysql mysql -u root -ppassword -e "SHOW DATABASES;"

echo -e "${GREEN}🎉 MySQL 9.0 está pronto!${NC}"