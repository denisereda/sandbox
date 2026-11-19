#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "${REGISTRY}${FRONTEND_IMAGE}:latest" \
  --tag "${REGISTRY}${FRONTEND_IMAGE}:${VERSION}" \
  --pull \
  --no-cache \
  --push \
  .
