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

sleep 10
# 准备环境
funcPrepareEnvironment(){
systemctl stop firewalld.service && systemctl disable firewalld.service
sed -i 's|Selinux=enforcing|Selinux=disabled|g'  /etc/selinux/config
setenforce 0
sed -ri 's/.*swap.*/#&/'  /etc/fstab 
swapoff -a
}

# 部署docker
funcInstallDocker(){
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

# 添加k8s仓库源地址，安装kubeadm、kubelet、kubectl命令
funcInstallTools(){
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
systemctl enable kubelet.service
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
funcInstallDocker
funcInstallTools
elif [ $1 = "master" ];then
funcPrepareEnvironment
funcInstallDocker
funcInstallTools
funcInit
funcSetupMaster
else
echo "\033[31msorry, your enter has false!\033[0m"
fi
}
main $1

