#!/bin/bash
#data:18-01-2021

funcInit(){
chmod a+x /usr/bin/kubeadm
kubeadm init \
--kubernetes-version=v1.18.5 \
--image-repository registry.aliyuncs.com/google_containers \
--pod-network-cidr=10.24.0.0/16 \
--ignore-preflight-errors=Swap 
}

funcSetupMaster(){
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f /root/k8s/kube-flannel.yaml
}

main(){
funcInit
funcSetupMaster
}
main
