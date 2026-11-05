VERSION_BACKEND=""
VERSION_FRONTEND=""

# Отправка по SSH на удаленную машину
scp "src/backend/output/sandbox-backend-${VERSION}.tar.gz" ubuntu@153.51.117.227:/home/ubuntu/
scp "src/backend/output/sandbox-frontend-${VERSION}.tar.gz" ubuntu@153.51.117.227:/home/ubuntu/
