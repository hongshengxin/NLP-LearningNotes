
##第一节课

#### 一. Flask 的特点
* 适合微服务架构
* MVC设计模式
* 核心思想是解耦，降低各个模块之间耦合性

#### 二. Flask 的调试

在flask 启动时，可以添加参数

```
参数1   debug

1. 在app内设置debug mode模式，可以实现，修改完python代码后自动重启
2. threaded 是否开启多线程
3. port  指定端口号
4. host主机  默认是127.0.0.1  指定为0.0.0.0代表本机所有IP
5. debug pin 输入pin码后可以在页面进行调试

```

#### 三. flask_script扩展库，使flask支持命令行参数

```
# manage.py

from flask_script import Manager

from myapp import app

manager = Manager(app)

@manager.command
def hello():
    print "hello"

if __name__ == "__main__":
    manager.run()
    
```

启动方式也更新为“python **.py runserver **”,可设置的参数有如下：

```
optional arguments:
  -?, --help            show this help message and exit
  -h HOST, --host HOST
  -p PORT, --port PORT
  --threaded
  --processes PROCESSES
  --passthrough-errors
  -d, --debug           enable the Werkzeug debugger (DO NOT use in production
                        code)
  -D, --no-debug        disable the Werkzeug debugger
  -r, --reload          monitor Python files for changes (not 100% safe for
                        production use)
  -R, --no-reload       do not monitor Python files for changes
  --ssl-crt SSL_CRT     Path to ssl certificate
  --ssl-key SSL_KEY     Path to ssl key
```

### 四. 路由的管理

* 使用的时候容易出现循环引用的问题
* 使用懒加载的方法
* 使用蓝图的方法

     代表一种规则
     
     
### 五. 操作数据库

   

