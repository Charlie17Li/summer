#!/bin/bash

set -e

REPO_ROOT=$(dirname ${BASH_SOURCE[0]})/..
source "$REPO_ROOT"/hack/util.sh

KUBECONFIG=${KUBECONFIG:-"$HOME/.kube/config"}
KUBECONTEXT=${KUBECONTEXT:-"karmada-host"}

KARMADA_CONFIG=${KARMADA_CONFIG:-"$HOME/.kube/karmada-apiserver.config"}
KARMADA_CONTEXT=${KARMADA_CONTEXT:-"karmada-apiserver"}

kubectl apply -f prometheus-config.yaml --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"
kubectl get pod --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT" | grep prometheus | awk '{print$1}' | xargs kubectl delete pod --kubeconfig "$KUBECONFIG" --context "$KUBECONTEXT"