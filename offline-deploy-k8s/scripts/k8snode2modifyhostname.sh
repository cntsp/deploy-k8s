#!/bin/bash
#data:18-01-2021

nodegroup=(k8snode1 k8snode2 k8snode3)
# 修改主机名
funcModifyHostname(){
hostname ${nodegroup[1]}
sed -i 's|preserve_hostname:false|preserve_hostname: true|g' /etc/cloud/cloud.cfg
sudo cat > /etc/hostname <<EOF
${nodegroup[1]}
EOF
}
funcModifyHostname
