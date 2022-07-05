#!/bin/bash

kubectl apply -f prometheus-config.yaml --context karmada-host
kubectl get pod --context karmada-host | grep prometheus | awk '{print$1}' | xargs kubectl delete pod --context karmada-host