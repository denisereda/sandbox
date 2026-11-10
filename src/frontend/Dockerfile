# Стадия сборки сервиса
FROM node:16.20.0-alpine3.18 AS builder

# Копируем исходники внутрь образа
COPY . .

# Устанавливаем зависимости
RUN npm install

# Собираем приложение
ENV NODE_ENV=production
RUN npm run build -- --dest "/app/build/site"

# Стадия подготовки образа сервиса
FROM node:16.20.0-alpine3.18 AS runtime

# Устанавливаем web-сервер
RUN npm install -g http-server

# Создаем сервисного пользователя, если его нет
RUN addgroup -S sandbox-frontend && adduser -S sandbox-frontend -G sandbox-frontend

# Создаем директорию для приложения
RUN mkdir -p /opt/sandbox/frontend
RUN chown -R sandbox-frontend:sandbox-frontend /opt/sandbox/frontend

# Копируем файлы сайта
COPY --from=builder "/app/build/site" /opt/sandbox/frontend

# Экспонируем порт и устанавливаем команду старта
EXPOSE 8888

# USER sandbox-frontend
ENTRYPOINT ["http-server", "/opt/sandbox/frontend", "-p", "8888", "--proxy", "http://sandbox-backend:8081"]