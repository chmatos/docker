# MySQL Docker Setup

Esta configuração fornece uma instância MySQL compartilhada com múltiplos databases pré-configurados.

## Configuração

- **MySQL Version**: 8.0.3
- **Root Password**: `db3921ch`
- **Porta**: 3306
- **phpMyAdmin**: http://localhost:8080

## Databases Criados

Os seguintes databases são criados automaticamente:

### Ambientes de Desenvolvimento
- `app_development` - Para desenvolvimento
- `app_testing` - Para testes
- `app_production` - Para produção

### Projetos
- `project_alpha` - Projeto Alpha
- `project_beta` - Projeto Beta  
- `project_gamma` - Projeto Gamma

### Utilitários
- `sandbox` - Para testes gerais

## Como Usar

### Iniciar os containers
```bash
cd mysql
docker-compose up -d
```

### Parar os containers
```bash
docker-compose down
```

### Conectar via linha de comando
```bash
# Conectar como root
../scripts/connect-mysql.sh

# Conectar a um database específico
../scripts/connect-mysql.sh app_development
```

### Listar databases
```bash
../scripts/list-databases.sh
```

### Acessar phpMyAdmin
Abra http://localhost:8080 no navegador
- **Usuário**: root
- **Senha**: db3921ch

## Volumes

- `shared_mysql_data`: Dados persistentes do MySQL
- `./mysql-init`: Scripts de inicialização
- `./backups`: Backups do MySQL
- `./logs`: Logs do MySQL

## Rede

Todos os containers estão na rede `shared-dev-network` para facilitar a comunicação entre diferentes projetos.

## Scripts Disponíveis

- `../scripts/connect-mysql.sh` - Conectar ao MySQL
- `../scripts/list-databases.sh` - Listar databases
- `../scripts/start-mysql.sh` - Iniciar MySQL
- `../scripts/restore-mysql-backup.sh` - Restaurar backup
- `../scripts/mysql-upgrade.sh` - Upgrade do MySQL