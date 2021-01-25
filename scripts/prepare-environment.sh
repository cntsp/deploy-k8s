#!/bin/bash
#date:18-01-2021

nodegroup=(k8snode1 k8snode2 k8snode3)
install_home="/root/k8s"
# 增加主机IP和主机名的对应关系
funcIncreaseIpHostname(){
i=0
while read -r line
do
sudo cat >> /etc/hosts <<EOF
$line ${nodegroup[$i]}
EOF
((i++))
done < $install_home/node.txt
}

funcCloseSwap(){
# 先临时关闭
swapoff -a
# 永久关闭，重启后生效
sed -i "s|/swapfile|# /swapfile|g" /etc/fstab
}

main(){
funcIncreaseIpHostname
funcCloseSwap
}

main
