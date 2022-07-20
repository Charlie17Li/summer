#!/bin/bash
set -e

REPO_ROOT=$(dirname ${BASH_SOURCE[0]})/..
source "$REPO_ROOT"/hack/util.sh

KUBECONFIG=${KUBECONFIG:-"$HOME/.kube/config"}
KUBECONTEXT=${KUBECONTEXT:-"karmada-host"}

KARMADA_CONFIG=${KARMADA_CONFIG:-"$HOME/.kube/karmada-apiserver.config"}
KARMADA_CONTEXT=${KARMADA_CONTEXT:-"karmada-apiserver"}


# 在karmada-host 创建ClusterRole 和 SA
kubectl apply -f prometheus-rbac-setup.yaml --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"

# 在karmada-host 中创建SA，1.24版本创建SA不会自动创建Secret--https://blog.csdn.net/qq_33921750/article/details/124977220
cat <<EOF | kubectl apply --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT" -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: prometheus
  annotations:
    kubernetes.io/service-account.name: "prometheus"
EOF

# 在Karmada-apiserver 创建ClusterRole 和 SA
kubectl apply -f prometheus-rbac-setup.yaml --kubeconfig "$KARMADA_CONFIG" --context "$KARMADA_CONTEXT"
cat <<EOF | kubectl apply --kubeconfig "$KARMADA_CONFIG" --context "$KARMADA_CONTEXT" -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: prometheus
  annotations:
    kubernetes.io/service-account.name: "prometheus"
EOF

pod_name=`kubectl get secret --kubeconfig "$KARMADA_CONFIG" --context "$KARMADA_CONTEXT" | grep prometheus | awk '{print$1}'`
token=`kubectl get secret "$pod_name" -o=jsonpath={.data.token} --kubeconfig "$KARMADA_CONFIG" --context "$KARMADA_CONTEXT" | base64 -d`

echo "token is" $token

sed "s/karmada-token/$token/g" prometheus-config-template.yaml > prometheus-config.yaml

# 创建Prom需要的配置
kubectl apply -f prometheus-config.yaml --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"

# 创建rule
kubectl apply -f prometheus-rules.yaml --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"

# 部署Prom
kubectl apply -f prometheus-deployment.yaml --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"


