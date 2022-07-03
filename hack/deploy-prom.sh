#!/bin/bash
set -e

REPO_ROOT=$(dirname ${BASH_SOURCE[0]})/..
source "$REPO_ROOT"/hack/util.sh

KUBECONFIG=${KUBECONFIG:-"$HOME/.kube/config"}
KUBECONTEXT=${KUBECONTEXT:-}

# 创建ClusterRole 和 SA
kubectl apply -f prometheus-rbac-setup.yaml --config "$KUBECONFIG" --context "$KUBECONTEXT"

# 创建Prom需要的配置
kubectl apply -f prometheus-config.yaml --config "$KUBECONFIG" --context "$KUBECONTEXT"

# 部署Prom
kubectl apply -f prometheus-deployment.yaml --config "$KUBECONFIG" --context "$KUBECONTEXT"
