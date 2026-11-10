#! /bin/bash
# Чтобы скрипт завершался, если есть ошибки
set -xe

VERSION=$(date -u +%Y%m%d-%H%M%S)

source ../../.env

docker buildx build \
  --file $PWD/Dockerfile \
  --tag "${REGISTRY}/seredada-frontend-docker/sandbox-frontend:latest" \
  --tag "${REGISTRY}/seredada-frontend-docker/sandbox-frontend:${VERSION}" \
  --pull \
  --no-cache \
  --push \
  .
