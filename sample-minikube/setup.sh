#!/bin/bash

set -e

echo "======================================"
echo "Kubernetes学習環境のセットアップ開始"
echo "======================================"

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dockerのインストール確認
echo -e "\n${YELLOW}[1/4] Dockerの確認とインストール${NC}"
if command -v docker &> /dev/null; then
    echo "Dockerは既にインストールされています"
    docker --version
else
    echo "Dockerをインストールします..."

    # 古いバージョンの削除
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # 必要なパッケージのインストール
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # DockerのGPGキーを追加
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # リポジトリの設定
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Dockerのインストール
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # ユーザーをdockerグループに追加
    sudo usermod -aG docker $USER

    echo -e "${GREEN}Dockerのインストールが完了しました${NC}"
fi

# Dockerの起動
echo "Dockerを起動します..."
sudo service docker start

# kubectlのインストール確認
echo -e "\n${YELLOW}[2/4] kubectlの確認とインストール${NC}"
if command -v kubectl &> /dev/null; then
    echo "kubectlは既にインストールされています"
    kubectl version --client
else
    echo "kubectlをインストールします..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo -e "${GREEN}kubectlのインストールが完了しました${NC}"
fi

# minikubeのインストール確認
echo -e "\n${YELLOW}[3/4] minikubeの確認とインストール${NC}"
if command -v minikube &> /dev/null; then
    echo "minikubeは既にインストールされています"
    minikube version
else
    echo "minikubeをインストールします..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
    echo -e "${GREEN}minikubeのインストールが完了しました${NC}"
fi

# サンプルファイルの作成
echo -e "\n${YELLOW}[4/4] サンプルファイルの作成${NC}"
mkdir -p workspace/examples

# 01-pod.yaml
cat > workspace/examples/01-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  labels:
    app: demo
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
EOF

# 02-deployment.yaml
cat > workspace/examples/02-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

# 03-service.yaml
cat > workspace/examples/03-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: NodePort
EOF

# 04-configmap.yaml
cat > workspace/examples/04-configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database_url: "postgresql://localhost:5432/mydb"
  log_level: "info"
  app_mode: "development"
---
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo DATABASE_URL=$DATABASE_URL && echo LOG_LEVEL=$LOG_LEVEL && sleep 3600"]
    env:
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: log_level
EOF

# 05-namespace.yaml
cat > workspace/examples/05-namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: development
---
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
apiVersion: v1
kind: Pod
metadata:
  name: dev-pod
  namespace: development
spec:
  containers:
  - name: nginx
    image: nginx:1.25
---
apiVersion: v1
kind: Pod
metadata:
  name: prod-pod
  namespace: production
spec:
  containers:
  - name: nginx
    image: nginx:1.25
EOF

echo -e "${GREEN}サンプルファイルの作成が完了しました${NC}"

echo -e "\n======================================"
echo -e "${GREEN}セットアップが完了しました！${NC}"
echo "======================================"
echo ""
echo "次のステップ:"
echo "1. 新しいシェルを起動するか、以下を実行してください:"
echo "   newgrp docker"
echo ""
echo "2. クラスタを起動します:"
echo "   ./start.sh"
echo ""
echo "3. 動作確認:"
echo "   kubectl get nodes"
echo ""