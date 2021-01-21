#!/bin/bash
#data:18-01-2021


funcLoadImages(){
for images in $(ls |grep .docker)
do
    docker load -i $images
done
}
funcLoadImages
