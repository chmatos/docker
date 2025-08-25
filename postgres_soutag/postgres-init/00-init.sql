-- Inicialização PostgreSQL Soutag
-- Este arquivo garante que o PostgreSQL com PostGIS está funcionando corretamente

-- Verificar se PostGIS está disponível
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

SELECT 'PostgreSQL Soutag inicializado com sucesso!' as status;
SELECT PostGIS_Version() as postgis_version;