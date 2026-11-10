# Используем легковесный образ alpine с установленным Go
FROM golang:alpine AS builder

# Устанавливаем зависимости для компиляции (если нужны сторонние пакеты)
RUN apk add --no-cache git

# Копируем исходники внутрь образа
WORKDIR /app
COPY . .

# Собираем проект статически
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o "./build/app" ./cmd/api/main.go ./cmd/api/router.go

# Создаем финальный образ с минимальным объемом
FROM alpine:latest AS runtime

WORKDIR /app

# Устанавливаем зависимости для работы
RUN apk add --no-cache curl

# Копируем исполняемый файл из промежуточного образа
COPY --from=builder "/app/build/app" ./

# Экспортируем порт, на котором работает ваше приложение
EXPOSE 8081

# Запускаем приложение
CMD ["./app"]