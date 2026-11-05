# Стадия сборки сервиса
FROM node:16.20.0-alpine3.18 AS builder

ARG VERSION="0.0.1"

# Копируем исходники внутрь образа
WORKDIR /app
COPY . .

# Устанавливаем зависимости
RUN npm install

# Собираем приложение
ENV NODE_ENV=production
RUN npm run build -- --dest "/app/build/frontend-${VERSION}/site"