# Kubernetes 学習環境（minikube使用）

WSL2のUbuntu上でminikubeを使ってKubernetesを学習するための環境です。

## 前提条件

- WSL2がインストールされている
- Ubuntuがインストールされている
- 8GB以上のメモリ推奨

## セットアップ

### 0. 準備
```bash
chmod +x *.sh
```

### 1. 初回セットアップ
以下をインストールするスクリプトを実行する
- Docker
- kubectl
- minikube

```bash
./setup.sh
```

### 2. クラスタの起動
クラスタを起動します。完了までに時間がかかる可能性があります。ターミナルを占有することはないため待機してください。
```bash
./start.sh
```

### 3. 動作確認
```bash
kubectl get nodes
kubectl get pods -A
minikube status
```

### 4. ダッシュボードの起動（オプション）
```bash
minikube dashboard
```

## 基本的な使い方

### minikubeコマンド
```bash
# クラスタの状態確認
minikube status

# クラスタの停止
./stop.sh
# または
minikube stop

# クラスタの起動
./start.sh
# または
minikube start

# クラスタの削除
minikube delete

# アドオンの一覧
minikube addons list

# アドオンの有効化（例：metrics-server）
minikube addons enable metrics-server

# アドオンの無効化
minikube addons disable metrics-server

# ノードへのSSH
minikube ssh

# サービスのURL取得
minikube service  --url

# サービスをブラウザで開く
minikube service
```

## よく使う kubectl コマンド
コマンドの一覧です。

コマンド実行に順序関係があります。このため上から順にコマンド実行するとエラーになるケースがあります。

### 確認系
```bash
# リソース一覧
## Pod一覧
kubectl get pods
## Deployment一覧
kubectl get deployments
## Service一覧
kubectl get services
## Node一覧
kubectl get nodes
## すべてのリソース
kubectl get all
## 全Namespace のすべてのリソース
kubectl get all -A

# 詳細確認
## Podの詳細情報
kubectl describe pod
## Deploymentの詳細情報
kubectl describe deployment
## Serviceの詳細情報
kubectl describe service

# ログ確認
## Podのログ
kubectl logs
## ログをリアルタイム表示
kubectl logs  -f
## 最新50行のログ
kubectl logs  --tail=50
```

### 作成系
```bash
# Podの作成（シンプルな方法）
kubectl run nginx --image=nginx

# Deploymentの作成
kubectl create deployment  --image=
kubectl create deployment nginx --image=nginx
kubectl create deployment nginx --image=nginx --replicas=3

# Serviceの作成
kubectl expose deployment  --port= --type=
kubectl expose deployment nginx --port=80 --type=NodePort
```

### 操作系
```bash
# スケーリング
kubectl scale deployment  --replicas=
kubectl scale deployment nginx --replicas=5

# Pod内でコマンド実行
kubectl exec -it  -- bash
kubectl exec -it  -- sh
kubectl exec  -- ls /usr/share/nginx/html

# ポートフォワード（ローカルからPodにアクセス）
kubectl port-forward pod/ 8080:80
kubectl port-forward service/ 8080:80
```

### 削除系
```bash
# リソースの削除
kubectl delete pod
kubectl delete deployment
kubectl delete service

# 複数まとめて削除
kubectl delete pod,service

# YAMLファイルで作成したリソースを削除
kubectl delete -f
```

### YAMLファイル関連
```bash
# YAMLファイルからリソース作成
kubectl apply -f
kubectl apply -f workspace/examples/02-deployment.yaml

# ディレクトリ内の全YAMLを適用
kubectl apply -f workspace/examples/

# リソースをYAML形式で出力
kubectl get deployment nginx -o yaml
kubectl get pod nginx -o yaml

# 既存リソースからYAMLファイル生成
kubectl get deployment nginx -o yaml > my-deployment.yaml
```

## 実践例

### 実践1: 最初のPodを作成する
```bash
# 1. 単純なPodを作成
kubectl run nginx --image=nginx

# 2. Podの一覧を確認
kubectl get pods
> NAME    READY   STATUS    RESTARTS   AGE
> nginx   1/1     Running   0          10s
# READY=1/1、STATUS=Runningになるまで待機する

# 3. Podの詳細情報を確認
kubectl describe pod nginx
# IPアドレス、イベント、コンテナの状態などが表示される

# 4. Podのログを確認
kubectl logs nginx

# 5. Pod内でコマンドを実行
kubectl exec nginx -- ls /usr/share/nginx/html

# 6. Pod内に入る（対話モード）
kubectl exec -it nginx -- bash
# Pod内で
root@nginx:/# hostname
root@nginx:/# curl localhost
root@nginx:/# exit

# 7. Podを削除
kubectl delete pod nginx

# 8. 削除されたことを確認
kubectl get pods
> No resources found in default namespace.
```

### 実践2: Deploymentで複数のPodを管理する
```bash
# 1. Deploymentを作成（3つのPodを起動）
kubectl create deployment nginx --image=nginx --replicas=3

# 2. Deploymentの一覧を確認
kubectl get deployments
> NAME    READY   UP-TO-DATE   AVAILABLE   AGE
> nginx   3/3     3            3           20s
# READY=3/3、UP-TO-DATE=3になるまで待機する

# 3. Podが3つ作成されたことを確認
kubectl get pods
> NAME                     READY   STATUS    RESTARTS   AGE
> nginx-7854ff8877-abc12   1/1     Running   0          30s
> nginx-7854ff8877-def34   1/1     Running   0          30s
> nginx-7854ff8877-ghi56   1/1     Running   0          30s

# 4. Deploymentの詳細を確認
kubectl describe deployment nginx
# レプリカ数、イベント、Pod のテンプレート情報などが表示される

# 5. すべてのリソースをまとめて確認
kubectl get all
> NAME                         READY   STATUS    RESTARTS   AGE
> pod/nginx-7854ff8877-abc12   1/1     Running   0          1m
> pod/nginx-7854ff8877-def34   1/1     Running   0          1m
> pod/nginx-7854ff8877-ghi56   1/1     Running   0          1m
>
> NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
> deployment.apps/nginx   3/3     3            3           1m
>
> NAME                               DESIRED   CURRENT   READY   AGE
> replicaset.apps/nginx-7854ff8877   3         3         3       1m
```

### 実践3: スケーリング（Podの数を変更）
```bash
# 1. 現在のPod数を確認
kubectl get pods
> NAME                     READY   STATUS    RESTARTS   AGE
> nginx-7854ff8877-abc12   1/1     Running   0          2m
> nginx-7854ff8877-def34   1/1     Running   0          2m
> nginx-7854ff8877-ghi56   1/1     Running   0          2m

# 2. スケールアウト: 5つに増やす
kubectl scale deployment nginx --replicas=5

# 3. 増えたことを確認
kubectl get pods
> NAME                     READY   STATUS    RESTARTS   AGE
> nginx-7854ff8877-abc12   1/1     Running   0          3m
> nginx-7854ff8877-def34   1/1     Running   0          3m
> nginx-7854ff8877-ghi56   1/1     Running   0          3m
> nginx-7854ff8877-jkl78   1/1     Running   0          10s  ← 新規
> nginx-7854ff8877-mno90   1/1     Running   0          10s  ← 新規

# 4. スケールイン: 1つに減らす
kubectl scale deployment nginx --replicas=1

# 5. 減ったことを確認
kubectl get pods
> NAME                     READY   STATUS    RESTARTS   AGE
> nginx-7854ff8877-abc12   1/1     Running   0          4m

# 6. 元に戻す（3つに）
kubectl scale deployment nginx --replicas=3
kubectl get pods
```

### 実践4: Serviceでアクセス可能にする
```bash
# 1. 現在のService一覧（まだ何もない状態）
kubectl get services
> NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
> kubernetes   ClusterIP   10.96.0.1            443/TCP   10m

# 2. Deploymentに対してServiceを作成（minikubeではNodePortを使用）
kubectl expose deployment nginx --port=80 --type=NodePort

# 3. Serviceが作成されたことを確認
kubectl get services
> NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
> kubernetes   ClusterIP   10.96.0.1               443/TCP        11m
> nginx        NodePort    10.96.123.456           80:30123/TCP   5s

# 4. Serviceの詳細を確認
kubectl describe service nginx
# Endpoints に Pod の IP アドレスが表示される

# 5. すべてのリソースを確認
kubectl get all
> NAME                         READY   STATUS    RESTARTS   AGE
> pod/nginx-7854ff8877-abc12   1/1     Running   0          5m
> pod/nginx-7854ff8877-def34   1/1     Running   0          5m
> pod/nginx-7854ff8877-ghi56   1/1     Running   0          5m
>
> NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
> service/kubernetes   ClusterIP   10.96.0.1               443/TCP        12m
> service/nginx        NodePort    10.96.123.456           80:30123/TCP   1m
>
> NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
> deployment.apps/nginx   3/3     3            3           5m
>
> NAME                               DESIRED   CURRENT   READY   AGE
> replicaset.apps/nginx-7854ff8877   3         3         3       5m

# 6. minikubeでServiceのURLを取得
minikube service nginx --url
> http://192.168.49.2:30123

# 7. ブラウザで開く（自動的にブラウザが起動）
minikube service nginx
```

### 実践5: ログの確認とリアルタイム監視
```bash
# 1. Pod名を確認
kubectl get pods
> NAME                     READY   STATUS    RESTARTS   AGE
> nginx-7854ff8877-abc12   1/1     Running   0          6m

# 2. 特定のPodのログを表示
kubectl logs nginx-7854ff8877-abc12

# 3. 最新50行のログだけ表示
kubectl logs nginx-7854ff8877-abc12 --tail=50

# 4. リアルタイムでログを監視（Ctrl+Cで終了）
kubectl logs nginx-7854ff8877-abc12 -f

# 5. 別のターミナルからアクセスしてログを生成
# （別のターミナルで）
minikube service nginx --url
# ↑表示されたURLにブラウザまたはcurlでアクセス
curl http://192.168.49.2:30123

# または、Pod内からアクセス
kubectl exec -it nginx-7854ff8877-def34 -- bash
root@nginx:/# curl localhost
root@nginx:/# exit

# （元のターミナルで）ログが流れるのを確認
```

### 実践6: curlでアクセスして負荷分散を確認
```bash
# 1. 各PodのHTMLをカスタマイズ
kubectl get pods
kubectl exec nginx-7854ff8877-abc12 -- sh -c 'echo "Response from POD-1" > /usr/share/nginx/html/index.html'
kubectl exec nginx-7854ff8877-def34 -- sh -c 'echo "Response from POD-2" > /usr/share/nginx/html/index.html'
kubectl exec nginx-7854ff8877-ghi56 -- sh -c 'echo "Response from POD-3" > /usr/share/nginx/html/index.html'

# 2. WSLから直接curlでアクセス（URLは minikube service nginx --url で確認）
curl http://192.168.49.2:30123
> Response from POD-2

# 3. 何度かアクセスしてランダムに振り分けられることを確認
for i in {1..10}; do curl -s http://192.168.49.2:30123; done
> Response from POD-1
> Response from POD-3
> Response from POD-2
> Response from POD-1
> Response from POD-2
> ...

# 4. または、テスト用のPodから内部的にアクセス
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- sh
~ $ curl http://nginx
> Response from POD-1
~ $ curl http://nginx
> Response from POD-3
~ $ exit
```

### 実践7: YAMLファイルを使ったリソース管理
```bash
# 1. 既存のDeploymentをYAML形式で出力
kubectl get deployment nginx -o yaml

# 2. YAMLファイルとして保存
kubectl get deployment nginx -o yaml > workspace/my-nginx-deployment.yaml

# 3. ファイルの中身を確認
cat workspace/my-nginx-deployment.yaml

# 4. サンプルファイルを適用
kubectl apply -f workspace/examples/02-deployment.yaml

# 5. 適用されたリソースを確認
kubectl get all

# 6. ディレクトリ内の全YAMLファイルを適用
kubectl apply -f workspace/examples/

# 7. YAMLファイルで作成したリソースを削除
kubectl delete -f workspace/examples/02-deployment.yaml
```

### 実践8: クリーンアップ
```bash
# 1. 個別に削除
kubectl delete service nginx
kubectl delete deployment nginx

# 2. 削除されたことを確認
kubectl get all
> NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
> service/kubernetes   ClusterIP   10.96.0.1            443/TCP   20m

# 3. または、一括削除（default namespaceの全リソース）
kubectl delete all --all

# 4. システムコンポーネントは別namespace（削除されない）
kubectl get pods -A
> NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
> kube-system   coredns-5d78c9869d-xxxxx          1/1     Running   0          30m
> kube-system   etcd-minikube                     1/1     Running   0          30m
> kube-system   kube-apiserver-minikube           1/1     Running   0          30m
> ...
```

## 学習の進め方（YAMLファイル使用）

### ステップ1: Pod の理解
```bash
kubectl apply -f workspace/examples/01-pod.yaml
kubectl get pods
kubectl describe pod simple-pod
kubectl logs simple-pod
kubectl delete -f workspace/examples/01-pod.yaml
```

### ステップ2: Deployment の理解
```bash
kubectl apply -f workspace/examples/02-deployment.yaml
kubectl get deployments
kubectl get pods
kubectl scale deployment nginx-deployment --replicas=5
kubectl delete -f workspace/examples/02-deployment.yaml
```

### ステップ3: Service の理解
```bash
kubectl apply -f workspace/examples/02-deployment.yaml
kubectl apply -f workspace/examples/03-service.yaml
kubectl get services

# minikubeでServiceにアクセス
minikube service nginx-service --url
# ブラウザで開く
minikube service nginx-service

# クリーンアップ
kubectl delete -f workspace/examples/03-service.yaml
kubectl delete -f workspace/examples/02-deployment.yaml
```

### ステップ4: ConfigMap の理解
```bash
kubectl apply -f workspace/examples/04-configmap.yaml
kubectl get configmaps
kubectl describe configmap app-config
kubectl get pods
kubectl logs configmap-pod
kubectl delete -f workspace/examples/04-configmap.yaml
```

### ステップ5: Namespace の理解
```bash
kubectl apply -f workspace/examples/05-namespace.yaml
kubectl get namespaces
kubectl get pods -n development
kubectl get pods -n production
kubectl delete -f workspace/examples/05-namespace.yaml
```

## クラスタの操作
```bash
# クラスタの状態確認
minikube status

# クラスタの停止
minikube stop

# クラスタの起動
minikube start

# クラスタの削除
minikube delete

# クラスタの再作成
minikube start --driver=docker
```

## トラブルシューティング

### クラスタが起動しない
```bash
# ログの確認
minikube logs

# 完全に削除して再作成
minikube delete
minikube start --driver=docker
```

### Dockerが動いていない
```bash
# Dockerの起動
sudo service docker start

# Docker の状態確認
sudo service docker status
```

### メモリ不足
```bash
# より少ないリソースで起動
minikube start --driver=docker --memory=4096 --cpus=2
```

### Serviceにアクセスできない
```bash
# ServiceのURLを確認
minikube service  --url

# minikubeのIPアドレスを確認
minikube ip

# NodePortを確認
kubectl get service
```

## 環境のクリーンアップ
```bash
# クラスタの完全削除
./cleanup.sh

# または手動で
minikube delete
```