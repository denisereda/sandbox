# Использование Nexus для заивки и стягивания артефактов

Чтобы запушить файл в репозиторий, используйте команды:

```bash
curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" --upload-file ./sandbox-backend-${VERSION}.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/sandbox-backend-${VERSION}.tar.gz

curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" --upload-file ./sandbox-frontend-${VERSION}.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/sandbox-frontend-${VERSION}.tar.gz
```

Чтобы стянуть файл из репозитория, используйте:

```bash
sudo curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" -o sandbox-backend-${VERSION}.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/${VERSION}/sandbox-backend-${VERSION}.tar.gz

sudo curl -u "${NEXUS_REPO_USER}:${NEXUS_REPO_PASS}" -o sandbox-frontend-${VERSION}.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/sandbox-frontend-${VERSION}.tar.gz
```
