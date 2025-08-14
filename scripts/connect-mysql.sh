#!/bin/bash

# Script para conectar ao MySQL
# Uso: ./connect-mysql.sh [database_name]

DATABASE=${1:-""}

if [ -z "$DATABASE" ]; then
    echo "Conectando ao MySQL como root..."
    docker exec -it shared-mysql mysql -uroot -pdb3921ch
else
    echo "Conectando ao database: $DATABASE"
    docker exec -it shared-mysql mysql -uroot -pdb3921ch -D "$DATABASE"
fi