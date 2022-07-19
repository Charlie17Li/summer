#!/bin/bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create ns monitor --kubeconfig=/root/.kube/karmada.config --context=karmada-host
cat <<EOF | helm upgrade --install grafana grafana/grafana --kubeconfig=/root/.kube/karmada.config --kube-context=karmada-host -n monitor -f -
service:
  enabled: true
  type: NodePort
  nodePort: 31802
  targetPort: 3000
  port: 80
EOF
# 获取登录密码
kubectl get secret --namespace monitor grafana -o jsonpath="{.data.admin-password}" --kubeconfig=/root/.kube/karmada.config --context=karmada-host | base64 --decode ; echo

