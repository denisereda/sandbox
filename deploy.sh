#!/usr/bin/env bash
# Скрипт выполняется на VM в каталоге с docker-compose.yml и .env.
# Пароль registry ожидается в stdin, чтобы не передавать его аргументами.
set -euo pipefail

: "${IMAGE_REGISTRY:?IMAGE_REGISTRY is required}"
: "${REGISTRY_USER:?REGISTRY_USER is required}"

APP_DIR="${APP_DIR:-$(pwd)}"
HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:8889/health}"

REGISTRY_PASSWORD="$(cat)"

cd "$APP_DIR"

# 1. Авторизация в registry
printf '%s' "$REGISTRY_PASSWORD" |
  sudo docker login "$IMAGE_REGISTRY" -u "$REGISTRY_USER" --password-stdin

# 2. Стягиваем образы указанной версии и перезапускаем сервисы.
# --force-recreate гарантирует применение изменений docker-compose.yml
# и пересоздание контейнеров даже при совпадении тега.
sudo docker compose pull
sudo docker compose up -d --remove-orphans --force-recreate
sudo docker image prune -f

# 3. Проверка работоспособности приложения
for _ in $(seq 1 30); do
  if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
    echo "Health check passed: $HEALTH_URL"
    exit 0
  fi
  sleep 2
done

echo "Health check failed: $HEALTH_URL" >&2
sudo docker compose ps >&2 || true
exit 1
