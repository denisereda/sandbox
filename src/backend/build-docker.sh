#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "${REGISTRY_BACKEND}/sandbox-backend:latest" \
  --tag "${REGISTRY_BACKEND}/sandbox-backend:${VERSION}" \
  --pull \
  --no-cache \
  --push \
  .
