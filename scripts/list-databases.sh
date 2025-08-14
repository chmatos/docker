#!/bin/bash

# Script para listar todos os databases disponíveis
echo "=== Databases disponíveis no MySQL ==="
docker exec shared-mysql mysql -uroot -pdb3921ch -e "SHOW DATABASES;" 2>/dev/null | grep -v "Warning"

echo ""
echo "=== Informações de conexão ==="
echo "Host: localhost"
echo "Porta: 3306"
echo "Usuário: root"
echo "Senha: db3921ch"
echo ""
echo "=== phpMyAdmin ==="
echo "URL: http://localhost:8080"
echo "Usuário: root"
echo "Senha: db3921ch"