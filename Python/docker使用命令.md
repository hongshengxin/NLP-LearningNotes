# dcoker 学习资料

## 1.docker 安装
* yum install -y epel-release


* yum install -y docker-io
* 安装后的配置文件：/etc/sysconfig/docker
* 启动docker 后台服务：service docker start
* docker version验证


##m 2. ac下docker常用命令
```

docker run -i -t <image_name/continar_id> /bin/bash  启动容器并启动bash（交互方式）

docker run -d -it  image_name   启动容器以后台方式运行(更通用的方式）

docker ps   列出当前所有正在运行的container

docker ps -a  列出所有的container

docker ps -l   列出最近一次启动的container

docker images  列出本地所有的镜像

docker rmi imagesID   删除指定的镜像id

docker rm CONTAINER ID   删除指定的CONTAINER id

docker diff 镜像名    查看容器的修改部分

docker kill CONTAINER ID   杀掉正在运行的容器

docker logs 容器ID/name   可以查看到容器主程序的输出

docker pull image_name    下载image

docker push image_name   发布docker镜像

docker version   查看docker版本

docker info   查看docker系统的信息

docker inspect 容器的id 可以查看更详细的关于某一个容器的信息

docker run -d  image-name   后台运行镜像

docker search 镜像名    查找公共的可用镜像

docker stop 容器名/容器 ID      终止运行的容器

docker restart 容器名/容器 ID    重启容器

docker commit  提交，创建个新镜像

docker build [OPTIONS] PATH | URL | -   利用 Dockerfile 创建新镜像

```

### 3. 数据卷

docker run -it -v /宿主机绝对路径目录：/容器内绝对路径目录  镜像名