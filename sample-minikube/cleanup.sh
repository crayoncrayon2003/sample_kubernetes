#!/bin/bash

echo "======================================"
echo "警告: クラスタを完全に削除します"
echo "======================================"
echo ""
read -p "本当に削除しますか? (yes/no): " confirmation

if [ "$confirmation" = "yes" ]; then
    echo "クラスタを削除します..."
    minikube delete
    echo ""
    echo "クラスタの削除が完了しました"
else
    echo "キャンセルしました"
fi