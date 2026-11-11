# Отправка по SSH на удаленную машину
VERSION="XXXXXX"

source ../../.env

scp "src/backend/output/sandbox-backend-${VERSION}.tar.gz" "${VM_USER_HOST}:/home/ubuntu/"
scp "src/backend/output/sandbox-frontend-${VERSION}.tar.gz" "${VM_USER_HOST}:/home/ubuntu/"
