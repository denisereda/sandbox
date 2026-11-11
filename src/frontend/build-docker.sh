#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "${REGISTRY_FRONTEND}/sandbox-frontend:latest" \
  --tag "${REGISTRY_FRONTEND}/sandbox-frontend:${VERSION}" \
  --pull \
  --no-cache \
  --push \
  .
