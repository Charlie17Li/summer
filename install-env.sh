

kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p /root/.kube && \
cp /etc/kubernetes/admin.conf /root/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml