#!/usr/bin/env bash
# Разворачивает сервисы docker compose (тег latest) на удаленной машине.
set -euo pipefail

source .env            # VM_USER_HOST, VM_USER, REGISTRY, NEXUS_REPO_*

VM_DIR=/opt/sandbox

echo "==> Деплой на ${VM_USER_HOST}:${VM_DIR}"

# Создаем каталог для приложения
ssh "${VM_USER_HOST}" "sudo mkdir -p '${VM_DIR}' && sudo chown '${VM_USER}' '${VM_DIR}'"

# Отправляем конфигурацию на удаленный сервер
scp ./docker-compose.yml ./.env "${VM_USER_HOST}:${VM_DIR}/"

# .env содержит пароль registry: закрываем от чтения другими пользователями VM.
# Файл принадлежит VM_USER, поэтому sudo не нужен.
ssh "${VM_USER_HOST}" "chmod 600 '${VM_DIR}/.env'"

# Логинимся в registry: пароль через stdin, чтобы не попал в ps и логи
printf '%s' "${NEXUS_REPO_PASS}" |
  ssh "${VM_USER_HOST}" sudo docker login "${REGISTRY}" -u "${NEXUS_REPO_USER}" --password-stdin

# Обновляем приложение
# Кавычки у REMOTE важны: переменные раскрываются на VM, а не локально.
# VM_DIR передан аргументом, поэтому внутри heredoc он доступен как $1.
ssh "${VM_USER_HOST}" bash -s -- "${VM_DIR}" <<'REMOTE'
set -euo pipefail
cd "$1"

sudo docker compose pull
sudo docker compose up -d --remove-orphans --force-recreate

sudo docker compose ps
REMOTE
