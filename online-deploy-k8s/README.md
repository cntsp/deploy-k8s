# 在线自动化脚本部署`k8s`

## 准备环境-三台阿里云机器

注册阿里云，选择抢占模式，20分钟内保证测试完成! 

![image-20210227155200327](images/image-20210227155200327.png)

**部署规划：**

| 主机名    | IP             | 角色   |
| --------- | -------------- | ------ |
| ubuntu001 | 172.24.127.111 | master |
| ubuntu002 | 172.29.68.239  | node1  |
| ubuntu003 | 172.24.127.112 | node2  |

注意事项：

- 要保证你的部署环境能正常拉取flannel默认的镜像地址:  `docker pull quay.io/coreos/flannel:v0.13.1-rc2`,否则flannel网络插件部署不成功

```shell
[root@ubuntu001 ~]# kubectl get nodes
NAME        STATUS   ROLES    AGE   VERSION
ubuntu001   Ready    master   85m   v1.18.5
ubuntu002   Ready    <none>   60m   v1.18.5
ubuntu003   Ready    <none>   65m   v1.18.5
```

