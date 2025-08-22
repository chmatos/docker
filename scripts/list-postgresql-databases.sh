#!/bin/bash

# Script para listar todos os databases disponíveis no PostgreSQL
echo "=== Databases disponíveis no PostgreSQL ==="
docker exec shared-postgresql psql -U postgres -c "\l" 2>/dev/null

echo ""
echo "=== Informações de conexão ==="
echo "Host: localhost"
echo "Porta: 5432"
echo "Usuário: postgres"
echo "Senha: pg3921ch"
echo ""
echo "=== pgAdmin ==="
echo "URL: http://localhost:8081"
echo "Email: admin@admin.com"
echo "Senha: admin"