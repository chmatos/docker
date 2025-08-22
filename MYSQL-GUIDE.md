# MySQL Docker Setup - Guia de Uso

## 📋 Visão Geral

Estrutura MySQL completa para desenvolvimento com múltiplos databases usando Docker Compose.

## 🏗️ Estrutura de Arquivos

```
mysql/
├── docker-compose.yml          # Configuração Docker (MySQL + phpMyAdmin)
├── .env.example               # Variáveis de ambiente
├── mysql-init/                # Scripts de inicialização
│   └── 00-init.sql
├── backups/                   # Backups dos databases
└── logs/                      # Logs do MySQL

scripts/
├── start-mysql.sh             # Inicia o MySQL
└── list-databases.sh          # Lista databases
```

## 🚀 Como Usar

### Iniciar MySQL
```bash
./scripts/start-mysql.sh
```

### Listar Databases
```bash
./scripts/list-databases.sh
```

### Gerenciar Databases via MySQL CLI
```bash
# Conectar ao MySQL
docker exec -it shared-mysql mysql -uroot -pdb3921ch

# Criar database
CREATE DATABASE meu_projeto;

# Usar database
USE meu_projeto;

# Listar databases
SHOW DATABASES;

# Deletar database
DROP DATABASE meu_projeto;
```

## 🔧 Configurações

### Portas e Serviços
- **MySQL**: `localhost:3306`
- **phpMyAdmin**: `http://localhost:8080`

### Credenciais Padrão
- **MySQL**:
  - Usuário: `root`
  - Senha: `db3921ch`
- **phpMyAdmin**:
  - Usuário: `root`
  - Senha: `db3921ch`

### Variáveis de Ambiente (.env)
```env
MYSQL_ROOT_PASSWORD=db3921ch
MYSQL_PORT=3306
PHPMYADMIN_PORT=8080
```

## 📊 Informações de Conexão

### Via Aplicação
```
Host: localhost
Port: 3306
Database: [nome_do_seu_database]
Username: root
Password: db3921ch
```

### Via phpMyAdmin
1. Acesse: `http://localhost:8080`
2. Login: `root` / `db3921ch`
3. Selecione ou crie seu database

## 🛠️ Comandos Docker Úteis

```bash
# Ver status dos containers
docker-compose -f mysql/docker-compose.yml ps

# Ver logs
docker-compose -f mysql/docker-compose.yml logs -f

# Parar serviços
docker-compose -f mysql/docker-compose.yml down

# Conectar diretamente via mysql
docker exec -it shared-mysql mysql -uroot -pdb3921ch

# Executar comando SQL
docker exec shared-mysql mysql -uroot -pdb3921ch -e "SHOW DATABASES;"

# Fazer backup manual
docker exec shared-mysql mysqldump -uroot -pdb3921ch nome_database > backup.sql

# Restaurar backup
docker exec -i shared-mysql mysql -uroot -pdb3921ch nome_database < backup.sql
```

## 📁 Backups Manuais

Para fazer backups dos databases:

```bash
# Backup de um database específico
docker exec shared-mysql mysqldump -uroot -pdb3921ch nome_database > mysql/backups/nome_database_$(date +%Y%m%d_%H%M%S).sql

# Backup de todos os databases
docker exec shared-mysql mysqldump -uroot -pdb3921ch --all-databases > mysql/backups/all_databases_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
docker exec -i shared-mysql mysql -uroot -pdb3921ch nome_database < mysql/backups/arquivo_backup.sql
```

## 🔍 Troubleshooting

### Container não inicia
```bash
# Verificar logs
docker-compose -f mysql/docker-compose.yml logs mysql

# Recriar containers
docker-compose -f mysql/docker-compose.yml down -v
docker-compose -f mysql/docker-compose.yml up -d
```

### Problemas de conexão
- Verificar se o container está rodando: `docker ps`
- Verificar porta disponível: `lsof -i :3306`
- Verificar credenciais no arquivo `.env`

### phpMyAdmin não carrega
- Aguardar MySQL ficar completamente pronto (healthcheck)
- Verificar logs: `docker-compose -f mysql/docker-compose.yml logs phpmyadmin`

## 💡 Dicas Úteis

### Comandos SQL Comuns
```sql
-- Listar databases
SHOW DATABASES;

-- Criar database
CREATE DATABASE nome_projeto CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Usar database
USE nome_projeto;

-- Listar tabelas
SHOW TABLES;

-- Ver estrutura da tabela
DESCRIBE nome_tabela;

-- Deletar database
DROP DATABASE nome_projeto;
```

### Configurações de Performance
O MySQL está configurado com as configurações padrão. Para projetos maiores, considere ajustar:
- `innodb_buffer_pool_size`
- `max_connections`
- `query_cache_size`