#!/bin/bash
#date:18-01-2021

install_home="/root/k8s"
# 通过deb包安装kubeadm、kubelet、kubectl
funcInstallKubeadm(){
sudo dpkg -i $install_home/conntrack_1%3a1.4.4+snapshot20161117-6ubuntu2_amd64.deb
sudo dpkg -i $install_home/cri-tools_1.13.0-01_amd64.deb
sudo dpkg -i $install_home/kubernetes-cni_0.8.7-00_amd64.deb
sudo dpkg -i $install_home/socat_1.7.3.2-2ubuntu2_amd64.deb
sudo dpkg -i $install_home/kubelet_1.18.5-00_amd64.deb
sudo dpkg -i $install_home/kubectl_1.18.5-00_amd64.deb
sudo dpkg -i $install_home/kubeadm_1.18.5-00_amd64.deb
}

funcSetupKubelet(){
cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS="--fail-swap-on=false"
EOF
sudo systemctl daemon-reload && systemctl enable kubelet
sleep 5
}
main(){
funcInstallKubeadm
funcSetupKubelet
}

main
