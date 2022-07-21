#!/bin/bash

kubeadm reset -f
docker ps -a | awk '{print$1}' | xargs docker rm -f 

rm -rf /etc/cni/net.d
rm -rf /etc/kubernetes
rm -rf /var/lib/karmada-etcd/

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
sysctl net.bridge.bridge-nf-call-iptables=1



