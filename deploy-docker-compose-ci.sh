#!/usr/bin/env bash
# Запускается на VM в каталоге с docker-compose.yml и .env.
# Пароль GHCR читается из stdin, чтобы не попадать в логи и список процессов.
set -euo pipefail

: "${REGISTRY_USER:?REGISTRY_USER is required}"

cd "$(dirname "$0")"

# Авторизуемся в GitHub Container Registry
sudo docker login ghcr.io -u "$REGISTRY_USER" --password-stdin

# Стягиваем образы указанной версии и пересоздаём контейнеры
sudo docker compose pull
sudo docker compose up -d --remove-orphans --force-recreate
sudo docker image prune -f

# Проверяем, что приложение отвечает
for _ in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:8889/health >/dev/null 2>&1; then
    echo "Health check passed"
    exit 0
  fi
  sleep 2
done

echo "Health check failed" >&2
sudo docker compose ps >&2 || true
exit 1
