
## 部署Prom
注意KUECONFIG, KARMADA_CONFIG路径
```
./hack/deploy-prom.sh
```

## 更新prom
如果修改了prometheus-config.yaml，需要重启Pod, 注意KUECONFIG, KARMADA_CONFIG路径
```
./hack/reset.sh
```

kubectl run net --image=quay.io/submariner/nettest:latest -- /bin/bash "-c" "while true; do sleep 1; done"
