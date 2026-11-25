#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

kubectl apply -f kubernetes/
kubectl rollout status deployment/sandbox-backend
kubectl rollout status deployment/sandbox-frontend
kubectl get service sandbox-frontend
