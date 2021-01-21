#!/bin/bash

ipgroup=(192.168.10.128 192.168.10.129 192.168.10.130)

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
