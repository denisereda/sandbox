#! /bin/bash
# Развертывание сервисов в docker compose на удаленной машине.
set -euo pipefail

source .env

VM_DIR="${VM_DIR:-/opt/sandbox}"

# 1. Готовим каталог для приложения на удаленной машине
ssh "${VM_HOST}" "sudo mkdir -p '${VM_DIR}' && sudo chown \"\$(id -u):\$(id -g)\" '${VM_DIR}'"

# 2. Копируем файлы
scp "./docker-compose.yml" "${VM_HOST}:${VM_DIR}/docker-compose.yml"
scp "./.env" "${VM_HOST}:${VM_DIR}/.env"

# 3. Авторизуемся в registry на удаленной машине
# Пароль передаем через stdin, чтобы он не попал в список процессов и логи
ssh "${VM_HOST}" "sudo docker login '${REGISTRY}' -u '${NEXUS_REPO_USER}' --password-stdin" <<< "${NEXUS_REPO_PASS}"

# 4. Стягиваем свежие latest-образы и перезапускаем сервисы
ssh "${VM_HOST}" bash -s <<EOF
set -xeuo pipefail
cd "${VM_DIR}"
sudo docker compose pull
sudo docker compose up -d --remove-orphans
sudo docker image prune -f
sudo docker compose ps
EOF
