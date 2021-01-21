# `ubuntu 18.05`上shell脚本离线一键部署`k8s-v1.18.5`

## 注意事项(单master存在单点故障，生产环境慎用)
1.  三台`ubuntu18.04`系统，主机名不要相同，保证时间相同
2.  在内网机器中，需要单独找一台部署机来执行脚本，保证部署机器与要部署三台节点正常通信
3.  修改4个文件的`IP`数组，`start.sh`、`./scripts/deploy-machine-node.sh`、`./scripts/nodex.txt`、`./scripts/install-kuboard.sh`
4. 默认`IP`数组中的第一个`IP`为master节点, 例如：`ipgroup`=(192.168.10.128 192.168.10.129 192.168.10.130),  那么192.168.10.128 就是master IP， 129和130就是node IP
5. 选择`kuboard`作为`k8s`容器集群web端的管理工具
6. 还有三个文件夹没有上传，一个是`deb`文件夹，一个是`master-images`文件，一个是`node-images`文件夹，deb里存放的是`docker-ce`、`kubectl`、`kubelet`、`kubeadm`软件的安装依赖包，`master-images`存放的是`master`节点的需要镜像，`node-images`存放的是`node`节点需要的镜像



## 项目的目录结构如下:

![项目图](./1.png)



目录树结构：

```bash
shupe@LAPTOP-QSG1JBV6 MINGW64 /d/gitworkdir
$ tree deploy-k8s/
deploy-k8s/
|-- 1.png
|-- README.md
|-- deb
|   |-- conntrack_1%3a1.4.4+snapshot20161117-6ubuntu2_amd64.deb
|   |-- containerd.io_1.3.7-1_amd64.deb
|   |-- cri-tools_1.13.0-01_amd64.deb
|   |-- docker-ce-cli_19.03.12~3-0~ubuntu-bionic_amd64.deb
|   |-- docker-ce_19.03.12~3-0~ubuntu-bionic_amd64.deb
|   |-- kubeadm_1.18.5-00_amd64.deb
|   |-- kubectl_1.18.5-00_amd64.deb
|   |-- kubelet_1.18.5-00_amd64.deb
|   |-- kubernetes-cni_0.8.7-00_amd64.deb
|   |-- libltdl7_2.4.6-14_amd64.deb
|   `-- socat_1.7.3.2-2ubuntu2_amd64.deb
|-- master-images
|   |-- coredns-1.6.7.docker
|   |-- eipwork-kuboard-v3.docker
|   |-- etcd-3.4.3-0.docker
|   |-- flannel-v0.13.0.docker
|   |-- kube-apiserver-v1.18.5.docker
|   |-- kube-controll-manager-v1.18.5.docker
|   |-- kube-proxy-v1.18.5.docker
|   |-- kube-scheduler-v1.18.5.docker
|   |-- kuboard-agent-v3.0.0.docker
|   |-- kuboard-agent-v3.docker
|   |-- kuboard-v2.0.5.4.docker
|   |-- metrics-server-v0.3.7.docker
|   `-- pause-3.2.docker
|-- node-images
|   |-- flannel-v0.13.0.docker
|   |-- kube-proxy-v1.18.5.docker
|   |-- kuboard-agent-v3.0.0.docker
|   |-- kuboard-agent-v3.docker
|   |-- metrics-server-v0.3.7.docker
|   `-- pause-3.2.docker
|-- scripts
|   |-- deploy-machine-node.sh
|   |-- init.sh
|   |-- install-docker.sh
|   |-- install-kubeadm.sh
|   |-- install-kuboard.sh
|   |-- k8snode1modifyhostname.sh
|   |-- k8snode2modifyhostname.sh
|   |-- k8snode3modifyhostname.sh
|   |-- load-images.sh
|   |-- loginkuboardtoken.sh
|   |-- node.txt
|   `-- prepare-environment.sh
|-- start.sh
`-- yaml
    |-- kube-flannel.yaml
    |-- kuboard-v2.yaml
    `-- metrics-server.yaml

5 directories, 50 files
```

由于这三个文件夹比较大，故存放在飞书上：[远程存放地址](https://l9yf9xcjc3.feishu.cn/drive/folder/fldcnWp3bTKezYfCJ7wih8fp48g)

执行前，需要把这个项目脚本的文件全部下载完整！！！



## 执行脚本

```bash
bash -xv  start.sh
```

1. 执行完成后会输出一条命令，就是`kubeadm join ... `，需要在另外两个node节点执行该命令，稍等片刻
   就可以在master节点上执行 `kubectl get nodes`
2. `kuboard`访问在master节点的` IP+32567 端口`,登录的token保存在master机器的`/root/token.txt`中