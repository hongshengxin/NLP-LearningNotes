
#1. 目标
由于Flask是一个轻量级的Web框架，自带app.run()方法能够提供http接口服务，测试环境下测试非常方便，但是如果在生产环境上单纯使用Flask还是会有些欠缺，如不支持多进程，不支持负载均衡。


* 负载均衡

tornado之类的框架只支持单核，所以多进程部署需要反向负载均衡。gunicorn本身就是多进程其实不需要。

* 静态文件支持

经过配置之后，nginx可以直接处理静态文件请求而不用经过Python服务器，Python服务器也可以返回特殊的http头将请求rewrite到静态文件。我说的是经过配置之后，你配置了吗？

* 抗并发压力

虽然不能提升qps，但是多一层前端，的确可以吸收一些瞬时的并发请求，让nginx先保持住连接，然后后端慢慢消化，但说实话这种情况下服务体验已经很糟糕了。但的确比服务挂掉强一些。



# 2 采用gunicorn 启动Flask程序

如下的一个简单的测试Flask程序wsgi.py文件，test接口返回接收的参数。

```
#--------------wsgi.py---------------
from flask import Flask
from flask import request
app = Flask(__name__)

@app.route('/test', method=['GET'])
def test():
  content = request.args.get('content')
  return content
if __name__ == '__main__':
  app.run()
```

```
 gunicorn -w 4 -b 0.0.0.1:9001 wsgi:app
 
-w: 代表启动4个进程，可以通过ps -ef | grep 9001可以看到四个PID；
-b: 打标绑定的IP和端口号,0.0.0.1表示不仅仅能在本台机器上访问，外网也可以访问，绑定的为9001端口
wsgi:app, wsgi代表文件名，app为对应到该文件中创建的Flask对象
此外还有其他参数:
--log-level LEVEL:表示日志级别，测试可以用DEBUG
--timeout: 超时时间，单位是秒
```

# 3. Nginx负载均衡
这里采用的单台机器 多个端口节点来实现负载均衡

```
$ wget https://nginx.org/download/nginx-1.14.0.tar.gz ##下载nginx源码
$ tar -zxvf nginx-1.14.0.tar.gz ##解压
$ cd nginx-1.14.0
$ ./configure --prefix=../nginx  ##安装到上层的nginx目录下
$ make  ##编译
$ make install #安装
$ cd ../可以看到有nginx-1.14.0和nginx两个文件夹，nginx-1.14.0是源码文件夹，nginx是安装文件夹
```

进入到nginx/conf/nginx.conf修改配置文件：
```
# 转发的两个节点，这里是单台机器的两个端口
upstream mycluster {
   server 127.0.0.1:9001 weight=1;
   server 127.0.0.1:9002 weight=1;
}
server {
    listen 9000; #暴露出去的端口号是9000
    server_name 127.0.01; # 暴露出去的IP是本台机器IP

    location / {
        proxy_pass http://mucluster; # 这里是upstream的名称
        root html;
       index index.html index.html;
    }
  }
```

启动nginx

```
$ cd nginx ##进入nginx安装目录
$ ./sbin/nginx ##启动nginx
```

如果有修改配置文件，需要重新启动nginx

```
$ cd nginx ##进入nginx安装目录
$ ./sbin/nginx -t ##验证nginx配置文件是否正确，看到nginx.conf test is successful说明配置文件正确
$ ./sbin/nginx -s reload ##启动nginx
```

至此，部署完成，直接访问http://ip:9000/test?content=测试即可通过nginx转发请求。