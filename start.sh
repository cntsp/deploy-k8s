#!/bin/bash
#date:15-01-2021

nodegroup=(k8snode1 k8snode2 k8snode3)
install_home="/root/k8s"
ipgroup=()

## 接收ip,生成IP数组
i=0
while read -r line
do
if [[ $i == 0 ]]; then
        ipgroup[0]=$line
elif [[ $i == 1 ]]; then
    	ipgroup[1]=$line
else
	ipgroup[2]=$line
fi
(( i++ ))
done < ./scripts/node.txt

echo -e "\033[31m 接收到的ipgroup组：\033[0m ${ipgroup[*]}"
## 往k8s节点服务器导入镜像
funcDeployImages(){
for(( i=0;i<${#ipgroup[@]};i++))
do
	if [ $i == 0 ];then
		# master 节点
		scp ./master-images/*.docker root@${ipgroup[$i]}:$install_home/
		ssh root@${ipgroup[$i]} -t -t "bash $install_home/load-images.sh"
	else
		# node 节点
		scp ./node-images/*.docker root@${ipgroup[$i]}:$install_home/
		ssh root@${ipgroup[$i]} -t -t "bash $install_home/load-images.sh"
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
	scp ./scripts/createdir.sh root@${ipgroup[$i]}:/root
	ssh root@${ipgroup[$i]} -t -t "bash /root/createdir.sh"
done
}


# 为k8snode1、k8snode2、k8snode3修改主机名、主机名和IP映射、安装Docker
funcThreeNodeInit(){
for((i=0;i<${#ipgroup[@]};i++))
do
	scp ./deb/*.deb ./scripts/* ./yaml/* root@${ipgroup[$i]}:$install_home/
	ssh root@${ipgroup[$i]} -t -t "bash $install_home/prepare-environment.sh"
	ssh root@${ipgroup[$i]} -t -t "bash $install_home/install-docker.sh"
	# echo "line 43 $i: $i"
	if [[ $i == 0 ]]; then
		ssh root@${ipgroup[$i]} -t -t "bash $install_home/k8snode1modifyhostname.sh"
	elif [[ $i == 1 ]]; then
		ssh root@${ipgroup[$i]} -t -t "bash $install_home/k8snode2modifyhostname.sh"
	else
		ssh root@${ipgroup[$i]} -t -t "bash $install_home/k8snode3modifyhostname.sh"
	fi
done
}

# 三节点通过deb包离线安装kubectl、kubelet、kubeadm
funcInstallDeb(){
for((i=0;i<${#ipgroup[$i]};i++))
do
	ssh root@${ipgroup[$i]} -t -t "bash $install_home/install-kubeadm.sh"
done
}

# 初始化k8snode1作为master节点
funcInitMaster(){
    ssh root@${ipgroup[0]} -t -t "bash $install_home/init.sh"
    # 启动kuboard
    ssh root@${ipgroup[0]} -t -t "bash $install_home/install-kuboard.sh"
}

funcLoginKuboardToken(){
    ssh root@${ipgroup[0]} -t -t "bash $install_home/loginkuboardtoken.sh"
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
    sleep 20
    # 打印登录kuboard的token
    funcLoginKuboardToken
    
}

main

