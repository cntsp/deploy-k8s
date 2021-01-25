#!/bin/bash
#data:18-01-2021

install_home="/root/k8s"
funcLoadImages(){
for images in $(ls $install_home|grep .docker)
do
    docker load -i $install_home/$images
done
}
funcLoadImages
