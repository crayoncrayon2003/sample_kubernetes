FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 基本ツールとDockerのインストール
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    vim \
    git \
    apt-transport-https \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Dockerのインストール
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# kubectl のインストール
RUN curl -LO https://dl.k8s.io/release/v1.28.2/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

# kind のインストール
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 && \
    chmod +x ./kind && mv ./kind /usr/local/bin/kind

# helm のインストール（オプション、後で使う可能性あり）
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 作業ディレクトリ
WORKDIR /workspace

CMD ["/bin/bash"]