#!/bin/bash
#date:19-01-2021

install_home="/root/k8s"
# kuboardv.2
funcInstallKuboardV2(){
kubectl apply -f $install_home/kuboard-v2.yaml
kubectl apply -f $install_home/metrics-server.yaml

}

# kuboardv.3暂时不用 
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
