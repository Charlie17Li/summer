#!/bin/bash
set -e

REPO_ROOT=$(dirname ${BASH_SOURCE[0]})/..
source "$REPO_ROOT"/hack/util.sh

KUBECONFIG=${KUBECONFIG:-"$HOME/.kube/karmada.config"}
KUBECONTEXT=${KUBECONTEXT:-"karmada-apiserver"}
KARMADACONTEXT=${KARMADACONTEXT:-"karmada-host"}

# 创建ClusterRole 和 SA
kubectl apply -f prometheus-rbac-setup.yaml --kubeconfig "$KUBECONFIG" --context "$KARMADACONTEXT"

# 在Karmada-apiserver 创建ClusterRole 和 SA
kubectl apply -f prometheus-rbac-setup.yaml --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"
pod_name=`kubectl get secret --context=karmada-apiserver | grep prometheus | awk '{print$1}'`
token=`kubectl get secret "$pod_name" -o=jsonpath={.data.token} --context=karmada-apiserver | base64 -d`

echo "token is" $token

sed "s/karmada-token/$token/g" prometheus-config-template.yaml > prometheus-config.yaml

# 创建Prom需要的配置
kubectl apply -f prometheus-config.yaml --kubeconfig "$KUBECONFIG" --context "$KARMADACONTEXT"

# 创建rule
kubectl apply -f prometheus-rules.yaml --kubeconfig "$KUBECONFIG" --context "$KARMADACONTEXT"

# 部署Prom
kubectl apply -f prometheus-deployment.yaml --kubeconfig "$KUBECONFIG" --context "$KARMADACONTEXT"


