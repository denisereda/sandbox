# Базовый образ Ubuntu LTS
FROM ubuntu:22.04

# Аргументы для настройки пользователя
ARG USERNAME=devops
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Устанавливаем системные зависимости с очисткой кеша
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Базовые утилиты
    tar curl git wget gosu ca-certificates openssh-client \
    # Для работы с контейнерами
    docker.io docker-compose \
    # Для Ansible и Python
    python3 python3-pip python3-venv \
    # Для Kubernetes
    apt-transport-https gnupg2 \
    # Утилиты для JSON/YAML
    jq \
    # Полезные инструменты
    zsh fzf tmux iputils-ping net-tools dnsutils netcat \
    # Для Groovy/Jenkins
    openjdk-17-jdk groovy \
    # Для PostgreSQL
    postgresql-client \
    # Для локалей и шрифтов
    locales fonts-powerline \
    && rm -rf /var/lib/apt/lists/*

# Настраиваем локали для Windows-совместимости
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TERM=xterm-256color

# Устанавливаем kubectl (явная установка последней версии)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Устанавливаем Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Устанавливаем k9s
RUN curl -sS https://webinstall.dev/k9s | bash

# Устанавливаем yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq

# Устанавливаем Docker Buildx
RUN mkdir -p ~/.docker/cli-plugins \
    && curl -sSL https://github.com/docker/buildx/releases/latest/download/buildx-linux-amd64 -o ~/.docker/cli-plugins/docker-buildx \
    && chmod +x ~/.docker/cli-plugins/docker-buildx

# Устанавливаем kubectx и kubens
RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx \
    && ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx \
    && ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Создаем не-root пользователя
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -aG docker $USERNAME

# Устанавливаем Ansible и Python-тулы
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir ansible ansible-lint ansible-navigator \
    && python3 -m pip install --no-cache-dir \
        jc ruamel.yaml xmltodict csvkit tomlkit python-dotenv

# Для windows добавляется группа root
RUN usermod -aG root,docker ${USERNAME}

# Переключаемся на пользователя
USER $USERNAME

# Настраиваем Zsh с минимальным конфигом
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Добавляем плагины в zsh
RUN sed -i 's/plugins=(git)/plugins=(git docker kubectl zsh-autosuggestions zsh-syntax-highlighting)/' /home/${USERNAME}/.zshrc

# Меняем тему на agnoster 
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' /home/${USERNAME}/.zshrc

WORKDIR /workspaces
SHELL ["/bin/zsh", "-c"]
