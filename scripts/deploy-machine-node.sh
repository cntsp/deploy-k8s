#!/bin/bash
#data:20-01-2021

# ipgroup=(192.168.96.67 192.168.96.76 192.168.96.68)
ipgroup=()
## 接收ip, 生成IP数组
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
done < /root/k8s/nodex.txt


funcNoPasswordLogin(){
echo -e "\033[31下面请按回车键：\033[0m"
ssh-keygen -t rsa
echo  -e "\033[31m下面需要输入 yes 和对应主机的密码 \033[0m"
for(( i=0;i<${#ipgroup[@]};i++))
do
	ssh-copy-id ${ipgroup[$i]}
done
)

funcNoPasswordLogin
