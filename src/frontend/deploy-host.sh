#! /bin/bash
# Скрипт необходимо передать на удаленную машину и выполнить после подключения через SSH
# Чтобы скрипт завершался, если есть ошибки
set -xe

FRONTEND_SITE_FOLDER_NAME="site"
SERVICE_NAME="sandbox-frontend"
SYSTEMD_SERVICE_NAME="${SERVICE_NAME}.service"
VERSION="20261105-141159" # <-- ОПРЕДЕЛИТЕ НУЖНУЮ ВЕРСИЮ ТУТ
NEXUS_REPO_FRONTEND_NAME="seredada-frontend"
NEXUS_REPO_URL=http://93.77.166.24:8081

DOWNLOAD_PATH="/tmp/sandbox/frontend"
SERVICE_PATH="/opt/sandbox/frontend"
RELEASE_FILES_PATH="${DOWNLOAD_PATH}/frontend-${VERSION}"

RELEASE_SITE_FOLDER_PATH="${RELEASE_FILES_PATH}/${FRONTEND_SITE_FOLDER_NAME}"
RELEASE_SYSTEMD_FILE_PATH="${RELEASE_FILES_PATH}/${SYSTEMD_SERVICE_NAME}"

# Создаем сервисного пользователя, если его нет
sudo useradd --system --no-create-home --shell /usr/sbin/nologin --user-group "${SERVICE_NAME}"

# Создаем директории для сервиса, если их нет
mkdir -p "${DOWNLOAD_PATH}"
sudo mkdir -p "${SERVICE_PATH}"

# Скачиваем свежую версию сервиса
sudo curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" -o "${DOWNLOAD_PATH}/${SERVICE_NAME}-${VERSION}.tar.gz" ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/${SERVICE_NAME}-${VERSION}.tar.gz
# И распаковываем ее
tar -xzvf "${DOWNLOAD_PATH}/${SERVICE_NAME}-${VERSION}.tar.gz" -C "${DOWNLOAD_PATH}"

# Останавливаем сервис
sudo systemctl stop "${SYSTEMD_SERVICE_NAME}" 2>/dev/null || true

# Делаем бэкап старой версии сервиса
if [ -d "${SERVICE_PATH}/${FRONTEND_SITE_FOLDER_NAME}" ]; then
    sudo cp "${SERVICE_PATH}/${FRONTEND_SITE_FOLDER_NAME}" "${SERVICE_PATH}/${FRONTEND_SITE_FOLDER_NAME}.bak"
fi

# Делаем бэкап дескриптора сервиса
if [ -f "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}" ]; then
    sudo cp -rf "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}" "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}.bak"
fi

# Удаляем старую версию сервиса
if [ -d "${SERVICE_PATH}/${FRONTEND_SITE_FOLDER_NAME}" ]; then
    sudo rm -rf "${SERVICE_PATH}/${FRONTEND_SITE_FOLDER_NAME}"
fi

# Удаляем старую версию конфигурации
if [ -f "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}" ]; then
    sudo rm -rf "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"
fi

# Переносим свежую версию сервиса в целевую директорию
if [ -d "${RELEASE_SITE_FOLDER_PATH}" ]; then
    sudo cp -r "${RELEASE_SITE_FOLDER_PATH}" "${SERVICE_PATH}/${FRONTEND_SITE_FOLDER_NAME}"
fi

# Переносим свежую версию конфигурации в целевую директорию
if [ -f "${RELEASE_SYSTEMD_FILE_PATH}" ]; then
    sudo cp "${RELEASE_SYSTEMD_FILE_PATH}" "/etc/systemd/system/${SYSTEMD_SERVICE_NAME}"
fi

# Поставим необходимое ПО
sudo apt install nodejs npm
sudo npm install -g http-server

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
