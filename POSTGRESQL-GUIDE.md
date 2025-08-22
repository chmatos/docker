# PostgreSQL Docker Setup - Guia de Uso

## 📋 Visão Geral

Estrutura PostgreSQL completa para desenvolvimento com múltiplos databases usando Docker Compose.

## 🏗️ Estrutura de Arquivos

```
postgresql/
├── docker-compose.yml          # Configuração Docker (PostgreSQL + pgAdmin)
├── .env.example               # Variáveis de ambiente
├── postgresql-init/           # Scripts de inicialização
│   └── 00-init.sql
├── backups/                   # Backups dos databases
└── logs/                      # Logs do PostgreSQL

scripts/
├── start-postgresql.sh        # Inicia o PostgreSQL
├── list-postgresql-databases.sh  # Lista databases
└── postgresql-db-manager.sh   # Gerenciador completo
```

## 🚀 Como Usar

### Iniciar PostgreSQL
```bash
./scripts/start-postgresql.sh
```

### Listar Databases
```bash
./scripts/list-postgresql-databases.sh
```

### Gerenciar Databases
```bash
# Ver comandos disponíveis
./scripts/postgresql-db-manager.sh help

# Criar database
./scripts/postgresql-db-manager.sh create meu_projeto

# Listar databases
./scripts/postgresql-db-manager.sh list

# Conectar ao database
./scripts/postgresql-db-manager.sh connect meu_projeto

# Fazer backup
./scripts/postgresql-db-manager.sh backup meu_projeto

# Restaurar backup
./scripts/postgresql-db-manager.sh restore meu_projeto arquivo_backup.sql

# Deletar database
./scripts/postgresql-db-manager.sh drop meu_projeto
```

## 🔧 Configurações

### Portas e Serviços
- **PostgreSQL**: `localhost:5432`
- **pgAdmin**: `http://localhost:8081`

### Credenciais Padrão
- **PostgreSQL**:
  - Usuário: `postgres`
  - Senha: `pg3921ch`
- **pgAdmin**:
  - Email: `admin@admin.com`
  - Senha: `admin`

### Variáveis de Ambiente (.env)
```env
POSTGRES_PASSWORD=pg3921ch
POSTGRES_USER=postgres
POSTGRES_PORT=5432
PGADMIN_PORT=8081
PGADMIN_EMAIL=admin@admin.com
PGLADMIN_PASSWORD=admin
```

## 📊 Informações de Conexão

### Via Aplicação
```
Host: localhost
Port: 5432
Database: [nome_do_seu_database]
Username: postgres
Password: pg3921ch
```

### Via pgAdmin
1. Acesse: `http://localhost:8081`
2. Login: `admin@admin.com` / `admin`
3. Adicione servidor:
   - Host: `postgresql`
   - Port: `5432`
   - Username: `postgres`
   - Password: `pg3921ch`

## 🛠️ Comandos Docker Úteis

```bash
# Ver status dos containers
docker-compose -f postgresql/docker-compose.yml ps

# Ver logs
docker-compose -f postgresql/docker-compose.yml logs -f

# Parar serviços
docker-compose -f postgresql/docker-compose.yml down

# Conectar diretamente via psql
docker exec -it shared-postgresql psql -U postgres

# Executar comando SQL
docker exec shared-postgresql psql -U postgres -c "SELECT version();"
```

## 📁 Backups

Os backups são salvos automaticamente em `postgresql/backups/` com timestamp:
- Formato: `nome_database_YYYYMMDD_HHMMSS.sql`
- Exemplo: `meu_projeto_20231201_143022.sql`

## 🔍 Troubleshooting

### Container não inicia
```bash
# Verificar logs
docker-compose -f postgresql/docker-compose.yml logs postgresql

# Recriar containers
docker-compose -f postgresql/docker-compose.yml down -v
docker-compose -f postgresql/docker-compose.yml up -d
```

### Problemas de conexão
- Verificar se o container está rodando: `docker ps`
- Verificar porta disponível: `lsof -i :5432`
- Verificar credenciais no arquivo `.env`