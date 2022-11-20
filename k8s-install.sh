#!/bin/bash
sudo apt update -y
sleep 5
sudo apt install -y docker.io
sleep 3
sudo systemctl enable docker.service
sudo apt install apt-transport-https curl -y
sleep 3
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
sleep 2
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sleep 2
sudo mv ~/kubernetes.list /etc/apt/sources.list.d
sleep 2
sudo apt update -y
sleep 3
sudo apt install kubelet -y
sleep 3
sudo apt install kubeadm -y
sleep 3
sudo apt install kubectl -y
sleep 3
sudo apt-get install -y kubernetes-cni
sleep 3
sudo swapoff -a

lsmod | grep br_netfilter
sleep 2
sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sleep2
sudo mkdir /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF
sleep 7
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
sleep 5
mkdir -p $HOME/.kube
sleep 2
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sleep 1
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo ufw allow 6443
sudo ufw allow 6443/tcp

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sleep 2
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
sleep 2

kubectl get pods --all-namespaces

kubectl get componentstatus
