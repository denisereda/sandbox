#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

REGISTRY=""
VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "${REGISTRY}sandbox-backend:latest" \
  --tag "${REGISTRY}sandbox-backend:${VERSION}" \
  --pull \
  --no-cache \
  --load \
  --build-arg VERSION="${VERSION}" \
  .

docker create --name sandbox-backend sandbox-backend:latest

mkdir -p output
docker cp sandbox-backend:/app/build ./output

docker rm sandbox-backend

# Добавим в дистрибутив конфигурацию сервиса и скрипт установки
cp ./sandbox-backend.service "./output/build/backend-${VERSION}"

tar -czvf "./output/sandbox-backend-${VERSION}.tar.gz" -C ./output/build .

# Отправка по SSH
# scp "/output/sandbox-backend-${VERSION}" ubuntu@153.51.117.227:/home/ubuntu/build/backend

# Публикация в Nexus
curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" --upload-file ./output/sandbox-backend-${VERSION}.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/sandbox-backend-${VERSION}.tar.gz
