#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "sandbox-frontend:latest" \
  --tag "sandbox-frontend:${VERSION}" \
  --pull \
  --no-cache \
  --load \
  --target builder \
  .

docker create --name sandbox-frontend sandbox-frontend:latest

mkdir -p output
docker cp sandbox-frontend:/app/build "./output/frontend-${VERSION}"

docker rm sandbox-frontend

# Добавим в дистрибутив конфигурацию сервиса и скрипт установки
cp ./sandbox-frontend.service "./output/frontend-${VERSION}"

tar -czvf "./output/sandbox-frontend-${VERSION}.tar.gz" -C "./output/frontend-${VERSION}" .

# Отправка по SSH
# scp "/output/sandbox-frontend-${VERSION}" ubuntu@153.51.117.227:/home/ubuntu/build/frontend

# Публикация в Nexus
curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" --upload-file ./output/sandbox-frontend-${VERSION}.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/sandbox-frontend-${VERSION}.tar.gz
