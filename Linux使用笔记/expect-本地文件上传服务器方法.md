
##安装expect
```
brew install expect
```
##使用

1.必须以  #!/usr/bin/expect -f  开头

##

###下面是登录设备的一段代码
```
#!/usr/bin/expect -f

user=root

host=1.1.1.1

password=root

spawn $user@$host
set timeout 60
except {
　　"(yes/no)?" {

　　　　send "yes\n"

　　　　expect "*assword:*"
　　　　send "$password\n"
　　　}
　　"assword:" {
　　　　send "$password\n"

　　} timeout {
　　　　exit
　　} eof{
　　　　exit
　　}
}
```

###下面是上传服务文件的代码

```
scp Downloads/php-7.2.11tar.bz2 root@39.105.166.xx:/home/tmp

scp  上传命令

Downloads/php-7.2.11tar.bz2  表示本地上准备上传文件的路径和文件

root@39.105.166.xx 表示使用root用户登录远程服务器39.105.166.xx

:/home/tmp 上传到服务器的目录

```

###自动登录服务器并且上传文件

```
#注意使用spawn来执行的命令都是在当前机器来执行的，后面的send发出的命令是在服务器执行的
spawn ssh liyuanhong@192.168.1.122
expect "password"
send "pass\r"
expect "liyuanhong"
#登录成功后在服务端执行的命令
send "touch mmm.sh\r"
expect eof
EOF
```

##自动登录服务器并在服务器上执行脚本，[实力踩坑踩出来的](https://www.jianshu.com/p/d4c1ac10204d?utm_campaign)

```
expect -c "
spawn ssh kduser@172.18.8.35 \"
cd /var/hongsheng_xin
touch abcdefg.txt\"
expect \"*assword:\"
send \"Kingdee@2018\n\"
expect eof"


将要执行的脚本放在spawn后既可以，但是一定要让双引号的初始在spawn那一行
```