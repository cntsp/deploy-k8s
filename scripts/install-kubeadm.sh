#!/bin/bash
#date:18-01-2021

# 通过deb包安装kubeadm、kubelet、kubectl
funcInstallKubeadm(){
sudo dpkg -i ./conntrack_1%3a1.4.4+snapshot20161117-6ubuntu2_amd64.deb
sudo dpkg -i ./cri-tools_1.13.0-01_amd64.deb
sudo dpkg -i ./kubernetes-cni_0.8.7-00_amd64.deb
sudo dpkg -i ./socat_1.7.3.2-2ubuntu2_amd64.deb
sudo dpkg -i ./kubelet_1.18.5-00_amd64.deb
sudo dpkg -i ./kubectl_1.18.5-00_amd64.deb
sudo dpkg -i ./kubeadm_1.18.5-00_amd64.deb
}

funcSetupKubelet(){
cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS="--fail-swap-on=false"
EOF
sudo systemctl daemon-reload && systemctl restart kubelet
}
main(){
funcInstallKubeadm
funcSetupKubelet
}

main
