# `ubuntu`系统上shell脚本离线一键部署`k8s-v1.18.5`

#### 注意事项(单master存在单点故障，生产环境慎用)
1.  三台`ubuntu18.04`系统，主机名不要相同，保证时间相同
2.  在内网机器中，需要单独找一台部署机来执行脚本，保证部署机器与要部署三台节点正常通信
3.  修改修改4个文件的`IP`，`start.sh`、`./scripts/deploy-machine-node.sh`、`./scripts/nodex.txt`、`./scripts/install-kuboard.sh`
4. 选择`kuboard`作为`k8s`容器集群web端的管理工具



## 执行脚本

```bash
bash ./start.sh
```

1. 执行完成最后会输出一条命令，就是`kubeadm join ... `，需要在另外两个work节点执行该命令，稍等片刻
   就可以在master节点上执行 `kubectl get nodes`
2. `kuboard`访问在master节点的` IP+32567 端口`,登录的token保存在master机器的`/root/token.txt`中