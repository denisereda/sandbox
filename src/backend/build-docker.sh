#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "${REGISTRY}/seredada-backend-docker/sandbox-backend:latest" \
  --tag "${REGISTRY}/seredada-backend-docker/sandbox-backend:${VERSION}" \
  --pull \
  --no-cache \
  --push \
  .
