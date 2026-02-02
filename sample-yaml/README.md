# 前提条件
- Kubernetes のクラスタが起動している
- kubectl はインストール済み
- kubectl config current-context でクラスタにつながっている

# yamlファイルをクラスタに適用する
```
kubectl apply -f nginx-demo.yaml
```

クラスタが起動している状態で、yamlを適用する。

このためdockerのようなコンテナを立ち上げるといった表現にはならない。

またyamlは、クラスタやPodの状態を表している。Deploymentが、宣言したyamlファイルの状態を維持するイメージである。


# 作成されたリソースを確認
```
kubectl get all -n nginx-demo
```

# テスト
image「curlimages/curl」を使って、Namespace「nginx-demo」に 一時的な pod「tmp」を作成する。

この中で、sh（シェル）を起動する。

```
kubectl run tmp --rm -it --image=curlimages/curl -n nginx-demo -- sh
```

一時的なpod「tmp」の中から、Service 「nginx-service」に対して、 curl コマンドを実行することで、nginx にアクセスする。

curlを実行するたびに応答する pod の名前が変化する。

```
curl nginx-service
```

一時的な pod「tmp」から抜ける。「tmp」から抜けると一時的なpodは自動削除される。

```
exit
```

# yamlファイルをクラスタから除外する
```
kubectl delete -f nginx-demo.yaml
```