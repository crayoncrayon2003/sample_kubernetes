#!/bin/bash

# サンプルファイルを作成するスクリプト

mkdir -p /workspace/examples

cat > /workspace/examples/deployment.yaml << 'EOF'
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
---
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
  type: ClusterIP
EOF

cat > /workspace/examples/pod.yaml << 'EOF'
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

echo "サンプルファイルを作成しました: /workspace/examples/"