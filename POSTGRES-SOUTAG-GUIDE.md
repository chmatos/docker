# PostgreSQL Soutag (PostGIS) - Guia de Uso

## 📋 Visão Geral

PostgreSQL específico para o projeto Soutag com PostGIS habilitado, baseado no dump fornecido.

## 🏗️ Estrutura de Arquivos

```
postgres_soutag/
├── docker-compose.yml          # PostgreSQL + PostGIS + pgAdmin
├── .env.example               # Variáveis de ambiente
├── postgres-init/             # Scripts de inicialização
│   └── 00-init.sql           # Habilita PostGIS
├── pg_dumps/                  # Dumps SQL (inclui soutag_ch.sql)
├── backups/                   # Backups dos databases
└── logs/                      # Logs do PostgreSQL

scripts/
├── start-postgres-soutag.sh   # Inicia PostgreSQL Soutag
├── restore-soutag-dump.sh     # Restaura dump do Soutag
└── soutag-db-manager.sh       # Gerenciador específico
```

## 🚀 Como Usar

### 1. Iniciar PostgreSQL Soutag
```bash
./scripts/start-postgres-soutag.sh
```

### 2. Restaurar Dump do Soutag
```bash
./scripts/restore-soutag-dump.sh
```

### 3. Gerenciar Databases
```bash
# Ver comandos disponíveis
./scripts/soutag-db-manager.sh help

# Listar databases
./scripts/soutag-db-manager.sh list

# Conectar ao database principal
./scripts/soutag-db-manager.sh connect testdb

# Verificar PostGIS
./scripts/soutag-db-manager.sh postgis

# Fazer backup
./scripts/soutag-db-manager.sh backup testdb

# Backup completo do cluster
./scripts/soutag-db-manager.sh backup-cluster

# Executar SQL
./scripts/soutag-db-manager.sh sql "SELECT version();" testdb
```

## 🔧 Configurações

### Portas e Serviços
- **PostgreSQL**: `localhost:5433` (diferente do padrão 5432)
- **pgAdmin**: `http://localhost:8082`

### Credenciais (baseadas no dump)
- **PostgreSQL**:
  - Usuário: `bruno`
  - Senha: `senha123`
  - Database principal: `testdb`
- **pgAdmin**:
  - Email: `admin@soutag.com`
  - Senha: `admin123`

### Variáveis de Ambiente (.env)
```env
POSTGRES_USER=bruno
POSTGRES_PASSWORD=senha123
POSTGRES_DB=testdb
POSTGRES_PORT=5433
PGADMIN_PORT=8082
PGLADMIN_EMAIL=admin@soutag.com
PGLADMIN_PASSWORD=admin123
```

## 📊 Informações de Conexão

### Via Aplicação
```
Host: localhost
Port: 5433
Database: testdb
Username: bruno
Password: senha123
```

### Via pgAdmin
1. Acesse: `http://localhost:8082`
2. Login: `admin@soutag.com` / `admin123`
3. Adicione servidor:
   - Host: `postgres`
   - Port: `5432` (interno do container)
   - Username: `bruno`
   - Password: `senha123`

## 🗺️ PostGIS

Este PostgreSQL inclui PostGIS para funcionalidades geoespaciais:

```sql
-- Verificar versão do PostGIS
SELECT PostGIS_Version();

-- Listar extensions PostGIS
SELECT name, default_version, installed_version 
FROM pg_available_extensions 
WHERE name LIKE '%postgis%';

-- Criar coluna geométrica
ALTER TABLE minha_tabela ADD COLUMN geom geometry(POINT, 4326);

-- Criar índice espacial
CREATE INDEX idx_minha_tabela_geom ON minha_tabela USING GIST (geom);
```

## 📁 Restore do Dump

### Comando Manual de Restore
```bash
# Restaurar dump completo (inclui roles, databases, etc.)
docker exec -i postgres_soutag psql -U bruno < postgres_soutag/pg_dumps/soutag_ch.sql

# Ou usar o script automatizado
./scripts/restore-soutag-dump.sh
```

### Databases no Dump
Baseado no dump fornecido, os seguintes databases serão criados:
- `template_postgis` - Template com PostGIS
- `testdb` - Database principal do projeto

### Roles/Usuários no Dump
- `bruno` - Usuário principal (superuser)
- `luisa` - Usuário adicional
- `tagplus` - Usuário do sistema
- `postgres` - Usuário padrão

## 🛠️ Comandos Docker Úteis

```bash
# Ver status dos containers
docker-compose -f postgres_soutag/docker-compose.yml ps

# Ver logs
docker-compose -f postgres_soutag/docker-compose.yml logs -f

# Parar serviços
docker-compose -f postgres_soutag/docker-compose.yml down

# Conectar diretamente
docker exec -it postgres_soutag psql -U bruno -d testdb

# Executar comando SQL
docker exec postgres_soutag psql -U bruno -d testdb -c "SELECT PostGIS_Version();"
```

## 📁 Backups

### Backup de Database Específico
```bash
./scripts/soutag-db-manager.sh backup testdb
```

### Backup Completo (Cluster)
```bash
./scripts/soutag-db-manager.sh backup-cluster
```

Os backups são salvos em `postgres_soutag/backups/` com timestamp.

## 🔍 Troubleshooting

### Container não inicia
```bash
# Verificar logs
docker-compose -f postgres_soutag/docker-compose.yml logs postgres

# Recriar containers
docker-compose -f postgres_soutag/docker-compose.yml down -v
docker-compose -f postgres_soutag/docker-compose.yml up -d
```

### Problemas com PostGIS
```bash
# Verificar extensions
./scripts/soutag-db-manager.sh postgis

# Recriar extensions manualmente
docker exec postgres_soutag psql -U bruno -d testdb -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

### Conflito de Porta
Se a porta 5433 estiver em uso:
1. Edite `postgres_soutag/.env`
2. Altere `POSTGRES_PORT=5434` (ou outra porta livre)
3. Reinicie: `docker-compose -f postgres_soutag/docker-compose.yml restart`

## 💡 Diferenças dos Outros PostgreSQL

- **Porta**: 5433 (vs 5432 do PostgreSQL padrão)
- **Usuário**: bruno (vs postgres padrão)
- **PostGIS**: Habilitado por padrão
- **pgAdmin**: Porta 8082 (vs 8081 do PostgreSQL padrão)
- **Dump**: Inclui dados específicos do projeto Soutag