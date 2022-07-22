#!/bin/bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

KUBECONFIG=${KUBECONFIG:-"$HOME/.kube/config"}
KUBECONTEXT=${KUBECONTEXT:-"karmada-host"}

KARMADA_CONFIG=${KARMADA_CONFIG:-"$HOME/.kube/karmada-apiserver.config"}
KARMADA_CONTEXT=${KARMADA_CONTEXT:-"karmada-apiserver"}

kubectl create ns monitor --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"
cat <<EOF | helm upgrade --install grafana grafana/grafana --kubeconfig "$KUBECONFIG" --kube-context "$KUBECONTEXT" -n monitor -f -
persistence:
  enabled: true
  storageClassName: local-storage
  accessModes: ReadWriteMany
service:
  enabled: true
  type: NodePort
  nodePort: 31802
  targetPort: 3000
  port: 80
EOF
# 获取登录密码
kubectl get secret --namespace monitor grafana -o jsonpath="{.data.admin-password}" --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT" | base64 --decode ; echo

