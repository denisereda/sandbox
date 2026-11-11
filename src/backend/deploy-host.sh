#! /bin/bash
# Скрипт необходимо передать на удаленную машину и выполнить после подключения через SSH
# Чтобы скрипт завершался, если есть ошибки
set -xe

source ../../.env

BACKEND_GO_FILE_NAME="app"
SERVICE_NAME="sandbox-backend"
SYSTEMD_SERVICE_NAME="${SERVICE_NAME}.service"
VERSION="20261105-084648" # <-- ОПРЕДЕЛИТЕ НУЖНУЮ ВЕРСИЮ ТУТ
NEXUS_REPO_BACKEND_NAME="seredada-backend"
NEXUS_REPO_URL="http://${REGISTRY}"

DOWNLOAD_PATH="/tmp/sandbox/backend"
SERVICE_PATH="/opt/sandbox/backend"
RELEASE_FILES_PATH="${DOWNLOAD_PATH}/backend-${VERSION}"

RELEASE_GO_FILE_PATH="${RELEASE_FILES_PATH}/${BACKEND_GO_FILE_NAME}"
RELEASE_SYSTEMD_FILE_PATH="${RELEASE_FILES_PATH}/${SYSTEMD_SERVICE_NAME}"

# Создаем сервисного пользователя, если его нет
sudo useradd --system --no-create-home --shell /usr/sbin/nologin --user-group "${SERVICE_NAME}"

# Создаем директории для сервиса, если их нет
mkdir -p "${DOWNLOAD_PATH}"
sudo mkdir -p "${SERVICE_PATH}"

# Скачиваем свежую версию сервиса
sudo curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" -o "${DOWNLOAD_PATH}/${SERVICE_NAME}-${VERSION}.tar.gz" ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/${SERVICE_NAME}-${VERSION}.tar.gz
# И распаковываем ее
tar -xzvf "${DOWNLOAD_PATH}/${SERVICE_NAME}-${VERSION}.tar.gz" -C "${DOWNLOAD_PATH}"

# Останавливаем сервис
sudo systemctl stop "${SYSTEMD_SERVICE_NAME}" 2>/dev/null || true

# Делаем бэкап старой версии сервиса
if [ -f "${SERVICE_PATH}/${BACKEND_GO_FILE_NAME}" ]; then
    sudo cp "${SERVICE_PATH}/${BACKEND_GO_FILE_NAME}" "${SERVICE_PATH}/${BACKEND_GO_FILE_NAME}.bak"
fi

# Делаем бэкап дескриптора сервиса
if [ -f "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}" ]; then
    sudo cp -rf "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}" "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}.bak"
fi

# Удаляем старую версию сервиса
if [ -f "${SERVICE_PATH}/${BACKEND_GO_FILE_NAME}" ]; then
    sudo rm -rf "${SERVICE_PATH}/${BACKEND_GO_FILE_NAME}"
fi

# Удаляем старую версию конфигурации
if [ -f "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}" ]; then
    sudo rm -rf "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"
fi

# Переносим свежую версию сервиса в целевую директорию
if [ -f "${RELEASE_GO_FILE_PATH}" ]; then
    sudo cp "${RELEASE_GO_FILE_PATH}" "${SERVICE_PATH}/${BACKEND_GO_FILE_NAME}"
fi

# Переносим свежую версию конфигурации в целевую директорию
if [ -f "${RELEASE_SYSTEMD_FILE_PATH}" ]; then
    sudo cp "${RELEASE_SYSTEMD_FILE_PATH}" "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"
fi

# Запускаем сервис
# 1. Перезагрузите конфигурацию systemd, чтобы он увидел новый файл
sudo systemctl daemon-reload

# 2. Запустите сервис прямо сейчас
sudo systemctl start "${SYSTEMD_SERVICE_NAME}"

# 3. Включите автозапуск при загрузке системы
sudo systemctl enable "${SYSTEMD_SERVICE_NAME}"

# Проверяем статус (должно быть "active (running)")
# sudo systemctl status "${SYSTEMD_SERVICE_NAME}"

# Проверяем логи
# sudo journalctl -u "${SYSTEMD_SERVICE_NAME}" -n 50 --no-pager

# Проверяем, отвечает ли сервис
# curl -v http://127.0.0.1:8081/products
