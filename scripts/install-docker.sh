#!/bin/bash

# 离线安装docker-ce
funcOfflineInstallDocker(){
s=`systemctl status docker |grep active| wc -l`
if [ $s -eq 0 ];then
sudo dpkg -i ./libltdl7_2.4.6-14_amd64.deb
sudo dpkg -i ./docker-ce-cli_19.03.12~3-0~ubuntu-bionic_amd64.deb
sudo dpkg -i ./containerd.io_1.3.7-1_amd64.deb
sudo dpkg -i ./docker-ce_19.03.12~3-0~ubuntu-bionic_amd64.deb
sudo systemctl enable docker
sudo systemctl start docker
else
echo -e "\033[31m docker服务已经安装在 $1 机器上了\033[0m"
fi
}

main(){
funcOfflineInstallDocker
}

main
