#!/bin/bash

kubeadm reset -f

rm -rf /etc/cni/net.d && \
rm -rf /etc/kubernetes && \
rm -rf /var/lib/etcd/*

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
sysctl net.bridge.bridge-nf-call-iptables=1

kubeadm init --pod-network-cidr=10.20.0.0/16 --image-repository galaxy.harbor.io/google-containers --service-cidr=10.96.0.0/16

kubeadm init --pod-network-cidr=10.30.0.0/16 --image-repository galaxy.harbor.io/google-containers --service-cidr=10.97.0.0/16
kubeadm join 10.10.41.21:6443 --token afuw4x.dzrmi01mostfpm6p \
    --discovery-token-ca-cert-hash sha256:72828af8c2eb10371ae9cf9fc14b349fec164e5527ae440417e11b95393db382

# oa1
kubeadm init --pod-network-cidr=10.40.0.0/16 --image-repository galaxy.harbor.io/google-containers --service-cidr=10.98.0.0/16
kubeadm join 10.10.42.21:6443 --token x4j0jh.aub71va3f3sb6ijw \
    --discovery-token-ca-cert-hash sha256:754f23b189364d20c52bf5b480dc439099038de1a8ccf0099ccc3acda5cc1987

# oa3
kubeadm init --pod-network-cidr=10.50.0.0/16 --image-repository galaxy.harbor.io/google-containers --service-cidr=10.99.0.0/16

subctl deploy-broker --repository=galaxy.harbor.io/library
subctl join broker-info.subm --cable-driver=vxlan --repository=galaxy.harbor.io/library

subctl join --kubeconfig=/root/.kube/oa2 broker-info.subm --clusterid "oa2" --cable-driver=vxlan --repository=galaxy.harbor.io/library


