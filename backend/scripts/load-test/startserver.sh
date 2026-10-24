#!/bin/bash
# Arranca o backend local para o teste de carga (porta 3300, base de TESTES local). Correr a partir de backend/scripts/load-test.
cd "$(dirname "$0")/../.." || exit 1
export NODE_ENV=development PORT=3300 DATABASE_URL=postgres://postgres:postgres@localhost:5432/teste DATABASE_SSL=false REDIS_URL=redis://localhost:6379 \
  JWT_ACCESS_SECRET=loadtest-access-secret-0123456789abcdef JWT_REFRESH_SECRET=loadtest-refresh-secret-0123456789abcdef RATE_LIMIT_MAX_REQUESTS=60 IP_FLOOD_MAX_REQUESTS=600
nohup node src/server.js > scripts/load-test/server.log 2>&1 &
echo $! > scripts/load-test/server.pid
