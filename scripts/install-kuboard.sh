#!/bin/bash
#date:19-01-2021

ipgroup=(192.168.10.128 192.168.10.129 192.168.10.130)

funcInstallKuboardV2(){
kubectl apply -f ./kuboard-v2.yaml
kubectl apply -f ./metrics-server.yaml

}

funcInstallKuboardV3(){
sudo docker run -d \
 --restart=unless-stopped \
 --name=kuboard \
 -p 10080:80/tcp \
 -p 10081:10081/udp \
 -p 10081:10081/tcp \
 -e KUBOARD_ENDPOINT="http://${ipgroup[0]}:10080" \
 -e KUBOARD_AGENT_SERVER_UDP_PORT="10081" \
 -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
 -v /home/kuboard-data:/data \
 eipwork/kuboard:v3
}

main(){
funcInstallKuboardV2
# funcInstallKuboardV3
}

main
