#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:?usage: $0 <version>}"

helm upgrade --install sandbox ./helm/sandbox \
  --namespace default \
  --set image.tag="${VERSION}" \
  --wait --timeout 10m
