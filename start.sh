#!/bin/bash
#date:15-01-2021


nodegroup=(k8snode1 k8snode2 k8snode3)
ipgroup=(192.168.10.128 192.168.10.129 192.168.10.130)

## 往k8s节点服务器导入镜像
funcDeployImages(){
for(( i=0;i<${#ipgroup[@]};i++))
do
	if [ $i == 0 ];then
		# master 节点
		scp ./master-images/*.docker root@${ipgroup[$i]}:/root
		ssh root@${ipgroup[$i]} -t -t "bash /root/load-images.sh"
	else
		# node 节点
		scp ./node-images/*.docker root@${ipgroup[$i]}:/root
		ssh root@${ipgroup[$i]} -t -t "bash /root/load-images.sh"
	fi
done
}

## 设置部署机到k8s节点机器的免密登录
funcNoPasswordLogin(){
echo -e "\033[31下面请按回车键：\033[0m"
ssh-keygen -t rsa
echo  -e "\033[31m下面需要输入 yes 和对应主机的密码 \033[0m"
for(( i=0;i<${#ipgroup[@]};i++))
do
	ssh-copy-id ${ipgroup[$i]}
done
}


# 为k8snode1、k8snode2、k8snode3修改主机名、主机名和IP映射、安装Docker
funcThreeNodeInit(){
for((i=0;i<${#ipgroup[@]};i++))
do
	scp ./deb/*.deb ./scripts/* ./yaml/* root@${ipgroup[$i]}:/root
	ssh root@${ipgroup[$i]} -t -t "bash /root/prepare-environment.sh"
	ssh root@${ipgroup[$i]} -t -t "bash /root/install-docker.sh"
	echo "line 43 $i: $i"
	if [[ $i == 0 ]]; then
		ssh root@${ipgroup[$i]} -t -t "bash /root/k8snode1modifyhostname.sh"
	elif [[ $i == 1 ]]; then
		ssh root@${ipgroup[$i]} -t -t "bash /root/k8snode2modifyhostname.sh"
	else
		ssh root@${ipgroup[$i]} -t -t "bash /root/k8snode3modifyhostname.sh"
	fi
done
}

# 三节点通过deb包离线安装kubectl、kubelet、kubeadm
funcInstallDeb(){
for((i=0;i<${#ipgroup[$i]};i++))
do
	ssh root@${ipgroup[$i]} -t -t "bash /root/install-kubeadm.sh"
done
}

# 初始化k8snode1作为master节点
funcInitMaster(){
    ssh root@${ipgroup[0]} -t -t "bash /root/init.sh"
    # 启动kuboard
    ssh root@${ipgroup[0]} -t -t "bash /root/install-kuboard.sh"
}

funcLoginKuboardToken(){
    ssh root@${ipgroup[0]} -t -t "bash /root/loginkuboardtoken.sh"
}
# main function
main(){
    # 部署机器到k8s节点做免密
    funcNoPasswordLogin
    # 初始化三节点的系统配置
    funcThreeNodeInit
    # 往k8s节点导入镜像
    funcDeployImages
    # 安装kubectl、kubelet、kubeadm
    funcInstallDeb
    # kubeadm初始化master节点
    funcInitMaster
    sleep 30
    # 打印登录kuboard的token
    funcLoginKuboardToken
    
}

main

