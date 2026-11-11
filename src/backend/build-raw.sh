#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "sandbox-backend:latest" \
  --tag "sandbox-backend:${VERSION}" \
  --pull \
  --no-cache \
  --load \
  --target builder \
  .

docker create --name sandbox-backend sandbox-backend:latest

mkdir -p "output/sandbox-backend-${VERSION}"
docker cp sandbox-backend:/app/build/app "./output/sandbox-backend-${VERSION}"

docker rm sandbox-backend

# Добавим в дистрибутив конфигурацию сервиса и скрипт установки
cp ./sandbox-backend.service "./output/sandbox-backend-${VERSION}"

tar -czvf "./output/sandbox-backend-${VERSION}.tar.gz" -C ./output/sandbox-backend-${VERSION} .

# Отправка по SSH
# scp "/output/sandbox-backend-${VERSION}" ubuntu@153.51.117.227:/tmp/sandbox/backend

# Публикация в Nexus
curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" --upload-file ./output/sandbox-backend-${VERSION}.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/sandbox-backend-${VERSION}.tar.gz
