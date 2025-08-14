-- Script para criar múltiplos databases
-- Este script é executado automaticamente quando o container MySQL é iniciado pela primeira vez

-- Criar databases para diferentes projetos
CREATE DATABASE IF NOT EXISTS `app_development` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `app_testing` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `app_production` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Criar databases para diferentes aplicações
CREATE DATABASE IF NOT EXISTS `project_alpha` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `project_beta` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `project_gamma` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Database para testes gerais
CREATE DATABASE IF NOT EXISTS `sandbox` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Mostrar databases criados
SHOW DATABASES;