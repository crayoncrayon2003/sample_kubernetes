#!/bin/bash

set -e

echo "======================================"
echo "Minikubeクラスタを起動します"
echo "======================================"

# Dockerの起動確認
if ! sudo service docker status > /dev/null 2>&1; then
    echo "Dockerを起動します..."
    sudo service docker start
    sleep 3
fi

# Minikubeの起動
echo "Minikubeを起動します..."
minikube start --driver=docker

# 状態確認
echo ""
echo "クラスタの状態:"
minikube status

echo ""
echo "ノードの確認:"
kubectl get nodes

echo ""
echo "======================================"
echo "クラスタの起動が完了しました！"
echo "======================================"
echo ""
echo "使い方:"
echo "  kubectl get pods -A           # 全てのPodを確認"
echo "  minikube dashboard            # ダッシュボードを起動"
echo "  kubectl apply -f workspace/examples/01-pod.yaml  # サンプルをデプロイ"
echo ""