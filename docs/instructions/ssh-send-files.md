# Отправка файлов на удаленную VM

```bash

# Сжатие
tar -czvf archive.tar.gz /папка

# Отправка по SSH
scp archive.tar.gz ubuntu@153.51.117.227:/home/ubuntu/

# Распаковка в существующую директорию 
tar -xzvf archive.tar.gz -C /путь/куда/распаковать
```
