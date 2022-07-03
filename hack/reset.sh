#!/bin/bash

kubectl apply -f prometheus-config.yaml
kubectl get pod | grep prometheus | awk '{print$1}' | xargs kubectl delete pod