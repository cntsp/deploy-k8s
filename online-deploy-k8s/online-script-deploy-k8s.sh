#!/bin/bash
#Author:cntsp
#date:27-02-2021

# MasterIp="172.24.127.111"

echo -e "\033[31m shell脚本在线部署k8s-v1.18.5 \033[0m"
echo -e "\033[31m 把该脚本拷贝到所有的部署节点上\033[0m"
echo -e "\033[32m 执行脚本前保证服务器时间是CST时间,所有节点的主机名不同\033[0m"
echo -e "\033[31mUsage:\033[0m master节点执行方式：./online-script-deploy-k8s.sh master"
echo -e "\033[31mUsage:\033[0m work节点执行方式：./online-script-deploy-k8s.sh work"
echo -e "测试前一定要保证环境和我一样哦，不然有可能出现问题！"

sleep 3
# 准备环境
funcPrepareEnvironment(){
systemctl stop firewalld.service && systemctl disable firewalld.service
sed -i 's|Selinux=enforcing|Selinux=disabled|g'  /etc/selinux/config
setenforce 0
sed -ri 's/.*swap.*/#&/'  /etc/fstab 
swapoff -a

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl -p /etc/sysctl.d/k8s.conf
}

# centos7部署docker
funcCentos7InstallDocker(){
cat >/etc/yum.repos.d/docker.repo <<EOF
[docker-ce-edge]
name=Docker CE Edge - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/\$basearch/edge
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF

yum install -y install docker-ce-19.03.6-3.el7

if [ ! -d /etc/docker ];then
mkdir /etc/docker
fi

cat >> /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": ["https://95tfc660.mirror.aliyuncs.com"]
}
EOF

systemctl daemon-reload && systemctl restart docker && systemctl enable docker
}

# Ubuntu系统部署docker
funcUbuntuInstallDocker(){
# update the apt package index and install packages to allow apt to use a repository over HTTPS 
sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
gnupg

# add docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Use the following command to set up the stable repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# List the versions available in your repo
apt-cache madison docker-ce

# Install a specific version using the version
sudo apt-get install docker-ce=19.03.6~3-0~ubuntu-bionic docker-ce-cli=19.03.6~3-0~ubuntu-bionic containerd.io

cat >> /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": ["https://95tfc660.mirror.aliyuncs.com"]
}
EOF

# start docker
sudo systemctl daemon-reload && systemctl start docker && systemctl restart docker
}


# Centos7添加k8s仓库源地址，安装kubeadm、kubelet、kubectl命令
funcCentos7InstallTools(){
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet-1.18.5 kubeadm-1.18.5 kubectl-1.18.5
# 启用kubelet
systemctl enable kubelet.service && systemctl start kubelet.service
}

# Ubuntu系统添加k8s仓库源地址，安装kubeadm、kubelet、kubectl命令
funcUbuntuInstallTools(){
# 使得 apt 支持 ssl 传输
# 直接在/etc/apt/sources.list里添加https://mirrors.aliyun.com/kubernetes/apt/是不行的，
# 因为这个阿里镜像站使用的ssl进行传输的，所以要先安装apt-transport-https并下载镜像站的密钥才可以进行下载。
apt-get update && apt-get install -y apt-transport-https
# 下载 gpg 密钥
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 
# 添加 k8s 镜像源
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
# 更新源列表
apt-get update
# 下载 kubectl，kubeadm以及 kubelet
sudo apt-get install -y kubelet=1.18.5-00 kubeadm=1.18.5-00 kubectl=1.18.5-00
sudo apt-mark hold kubelet kubeadm kubectl
}


# kubeadm init初始化部署
funcInit(){
chmod a+x /usr/bin/kubeadm
kubeadm init \
 --apiserver-advertise-address=${MasterIp} \
 --kubernetes-version=v1.18.5 \
 --image-repository registry.aliyuncs.com/google_containers \
 --pod-network-cidr=10.24.0.0/16 \
 --ignore-preflight-errors=Swap
}

# 配置master节点
funcSetupMaster(){
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
}

main(){
echo "接收的第一个参数是：$1"
sleep 3
if [ $1 = "work" ];then
funcCentos7InstallDocker
funcCentos7InstallTools

elif [ $1 = "master" ];then
funcPrepareEnvironment
funcCentos7InstallDocker
funcCnetos7InstallTools
funcInit
funcSetupMaster
else
echo "\033[31msorry, your enter has false!\033[0m"
fi
}
main $1

