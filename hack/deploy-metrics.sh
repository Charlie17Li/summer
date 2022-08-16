#!/bin/bash

cat > custom-values.yaml <<EOF
args:
- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP
EOF

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install -f custom-values.yaml --namespace kube-system metrics-server metrics-server/metrics-server --kubeconfig=/root/.kube/karmada.config --kube-context=karmada-host