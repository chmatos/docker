#!/bin/bash
# restore-mysql-backup.sh
# Restaura backup completo do MySQL no Docker

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
NC='\033[0m'

BACKUP_DIR="$HOME/mysql_recovery"
DOCKER_COMPOSE_DIR="$HOME/projetos/docker/mysql"

echo -e "${YELLOW}🔄 Iniciando restauração completa do MySQL...${NC}"

# Verificar se backup existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ Backup não encontrado em $BACKUP_DIR${NC}"
    exit 1
fi

# Verificar se docker-compose existe
if [ ! -f "$DOCKER_COMPOSE_DIR/docker-compose.yml" ]; then
    echo -e "${RED}❌ docker-compose.yml não encontrado em $DOCKER_COMPOSE_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}📊 Backup contém $(ls -1 "$BACKUP_DIR" | grep -E '^[a-zA-Z].*[^\.err|^\.pid]$' | wc -l | tr -d ' ') databases${NC}"
echo -e "${YELLOW}💾 Tamanho total: $(du -sh "$BACKUP_DIR" | cut -f1)${NC}"

# Confirmação
echo -e "${RED}⚠️  ATENÇÃO: Isso vai SUBSTITUIR todos os dados atuais do MySQL Docker!${NC}"
echo -e "${YELLOW}Databases que serão restaurados:${NC}"
ls -1 "$BACKUP_DIR" | grep -E '^[a-zA-Z]' | grep -v '\.' | head -200

read -p "🤔 Continuar com a restauração? (digite 'SIM' para confirmar): " confirm

if [ "$confirm" != "SIM" ]; then
    echo -e "${YELLOW}❌ Restauração cancelada pelo usuário${NC}"
    exit 0
fi

echo -e "${YELLOW}🛑 Parando MySQL Docker...${NC}"
cd "$DOCKER_COMPOSE_DIR"
docker-compose stop mysql 2>/dev/null || true

echo -e "${YELLOW}📦 Fazendo backup do volume atual (por segurança)...${NC}"
docker run --rm \
    -v shared_mysql_data:/source \
    -v "$HOME/mysql_backup_$(date +%Y%m%d_%H%M%S)":/backup \
    alpine sh -c "cp -r /source/* /backup/" 2>/dev/null || echo "Volume vazio, continuando..."

echo -e "${YELLOW}🗑️  Limpando dados atuais...${NC}"
docker run --rm \
    -v shared_mysql_data:/target \
    alpine sh -c "rm -rf /target/*"

echo -e "${YELLOW}📁 Copiando dados do backup...${NC}"
docker run --rm \
    -v shared_mysql_data:/target \
    -v "$BACKUP_DIR":/source \
    alpine sh -c "
        echo 'Copiando arquivos do sistema...'
        cp -r /source/* /target/
        echo 'Ajustando permissões...'
        chown -R 999:999 /target/
        chmod -R 755 /target/
        echo 'Restauração de arquivos concluída!'
    "

echo -e "${YELLOW}🚀 Iniciando MySQL com dados restaurados...${NC}"
docker-compose up -d mysql

echo -e "${YELLOW}⏳ Aguardando MySQL inicializar...${NC}"
timeout=120
counter=0

while [ $counter -lt $timeout ]; do
    if docker-compose exec -T mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo -e "${GREEN}✅ MySQL iniciado com sucesso!${NC}"
        break
    fi
    
    echo -n "."
    sleep 3
    counter=$((counter + 3))
done

if [ $counter -ge $timeout ]; then
    echo -e "${RED}❌ Timeout: MySQL não conseguiu iniciar${NC}"
    echo -e "${YELLOW}Verificando logs...${NC}"
    docker-compose logs --tail=20 mysql
    exit 1
fi

echo -e "${YELLOW}🔍 Verificando databases restaurados...${NC}"
echo "Databases disponíveis:"
docker-compose exec -T mysql mysql -u root -p"${MYSQL_ROOT_PASSWORD:-password}" -e "SHOW DATABASES;" | grep -v "Database\|information_schema\|performance_schema"

echo -e "${GREEN}🎉 Restauração concluída com sucesso!${NC}"
echo -e "${YELLOW}📋 Próximos passos:${NC}"
echo "1. Teste a conexão: docker exec -it shared-mysql mysql -u root -p"
echo "2. Verifique seus databases: docker exec shared-mysql mysql -u root -p -e 'SHOW DATABASES;'"
echo "3. Configure seus projetos Rails para usar os databases restaurados"
echo "4. phpMyAdmin disponível em: http://localhost:8080"