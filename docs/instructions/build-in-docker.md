# Сборка приложений в docker

Собрать артефакт в docker и вытащить его из образа можно несколькими способами. Выбор зависит от того, нужен ли вам бинарник «на лету» или как часть CI/CD-пайплайна.

Можно просто зайти в контейнер и скопировать артефакты в примонтированный раздел вручную:

```bash
docker run -it -v ./output:/output backend:latest sh
docker run -it -v ./output:/output backend:latest sh
```

## Способ 1: `docker create` + `docker cp` (быстрый, «ручной»)

Классический способ, если образ уже собран. Мы **создаём** контейнер, но не запускаем его, копируем файл и удаляем контейнер:

```bash
# 1. Создать контейнер (не запуская его)
docker create --name tmp-extract my-go-app:latest

# 2. Скопировать бинарник из контейнера в текущую папку
docker cp tmp-extract:/bin/app ./app

# 3. Удалить временный контейнер
docker rm tmp-extract

# 4. Дать права на исполнение (если не сохранились)
chmod +x ./app
```

Можно одной строкой:

```bash
docker create --name tmp my-go-app:latest && \
docker cp tmp:/bin/app ./app && \
docker rm tmp
```

Этот способ работает всегда, даже если Dockerfile не адаптирован под экспорт.

## Способ 2: `docker buildx --output` (современный, для CI/CD)

Если вы контролируете Dockerfile, можно собрать образ **сразу в файл на хосте**, без промежуточного контейнера. Для этого нужен этап, содержащий только артефакт (обычно на `scratch`).

Добавьте в конец Dockerfile отдельный этап-«экспорт»:

```dockerfile
# ... builder этап ...

# Этап, который содержит ТОЛЬКО артефакт
FROM scratch AS export
COPY --from=builder /app /app
```

И собирайте так (используется `buildx`, входит в современный Docker):

```bash
docker buildx build \
  --target export \
  --output type=local,dest=./out \
  .
```

В папке `./out/` появится файл `app`. Преимущества:

- ничего не создаётся в локальном хранилище Docker;
- работает в CI без Docker-демона на раннере (если использовать `buildx` с драйвером `docker-container` или `remote`);
- можно сразу собрать под нужную платформу (см. ниже).

Другие варианты вывода:

```bash
# В tar-архив
--output type=tar,dest=app.tar

# В OCI-образ на диск (без загрузки в daemon)
--output type=oci,dest=app.tar
```
