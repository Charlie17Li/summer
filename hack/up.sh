#!/bin/bash
set -e

REPO_ROOT=$(dirname ${BASH_SOURCE[0]})/..
source "$REPO_ROOT"/hack/util.sh

CLUSTER_NUM=${CLUSTER_NUM:-3}
CLUSTER_PREFIX=${CLUSTER_PREFIX:-"summer"}

for ((i = 0; i < $CLUSTER_NUM; i++)); do
    util::log_info "开始创建集群"

    cluster_name="$CLUSTER_PREFIX"-"$i"
    nohup kind create cluster --name "$cluster_name" >/dev/null 2>&1 &
done

# 同时为每个kind注册多个fake-node
for ((i = 0; i < $CLUSTER_NUM; i++)); do
    cluster_name="$CLUSTER_PREFIX"-"$i"
    for ((j = 0; j < 100; j ++)); do
        ready=`kubectl get nodes -owide --context kind-$cluster_name  | grep control-plane | awk '{print$2}'`
        if [ "$ready" == "Ready" ]; then
            break
        else
            printf "\r 等待%s集群就绪, %d/100" $cluster_name $j
        fi
    done

    if [ "$ready" != "Ready" ]; then
        exit 1
    fi

    # 当集群Ready以后,创建fake-node
    kubectl apply -f "$REPO_ROOT"/fake-kubelet-deploy.yaml
done

