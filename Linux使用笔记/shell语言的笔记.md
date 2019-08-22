#[shel学习笔记](http://www.hechaku.com/shell/)

##sh 文件的执行

一定要先给这个文件添加权限：，不然会报错，显示Permission denied
```
>>chmod u+x /usr/local/tars/cpp/script/create_tars_server.sh

>>在运行
```

##shell 特殊变量
$0    显示脚本文件名
$n    第N个变量名
$#    变量的个数

特殊参数$* 和$@
```
for TOKEN in $*
do
   echo $TOKEN
done
```

##shell 数组

```
#!/bin/sh

NAME[0]="Zara"
NAME[1]="Qadir"
NAME[2]="Mahnaz"
NAME[3]="Ayan"
NAME[4]="Daisy"
echo "First Index: ${NAME[0]}"
echo "Second Index: ${NAME[1]}"
```

## shell 算数运算符

记下有以下几点：

* 运算符和表达式之间必须有空格，例如2+2是不正确的，因为它应该写成2 + 2。

* ``，称为倒逗号之间应包含完整的表达。

```
#!/bin/sh

val=`expr 2 + 2`
echo "Total value : $val"
Total value : 4
```
## 条件语句

```
if [ expression ]
then
   Statement(s) to be executed if expression is true
else
   Statement(s) to be executed if expression is not true
fi
```

## 算数运算符

假设变量a=10,变量b=20：
```
+   `expr $a + $b` will give 30
-   `expr $a - $b` will give -10
*   `expr $a * $b` will give 200
/  	`expr $b / $a` will give 2
%   `expr $b % $a` will give 0
=   a=$b would assign value of b into a
==  [ $a == $b ] would return false.
!=  [ $a != $b ] would return true.

```

## 关系运算符

假设变量a=10,变量b=20：

```
-eq   	[ $a -eq $b ] is not true.  判断是否相等，相等返回true
-ne     [ $a -ne $b ] is true.  判断是否相等，不相等返回true
-gt     [ $a -gt $b ] is not true.   a>b  返回True
-lt     [ $a -lt $b ] is true.       a<b 返回true
-ge     [ $a -ge $b ] is not true.   a>=b 返回true
-le     [ $a -le $b ] is true.       a<=b 返回true
```

## 布尔运算
假设变量a=10,变量b=20：

```
!    [ ! false ] is true.
-o   [ $a -lt 20 -o $b -gt 100 ] is true.  或操作
-a		[ $a -lt 20 -a $b -gt 100 ] is false.  与操作
```

## selcet语句

```
select DRINK in tea cofee water juice appe all none
do
   case $DRINK in
      tea|cofee|water|all) 
         echo "Go to canteen"
         ;;
      juice|appe)
         echo "Available at home"
      ;;
      none) 
         break 
      ;;
      *) echo "ERROR: Invalid selection" 
      ;;
   esac
done
```

## shell 判断文件夹或文件是否存在
文件夹不存在则创建
```
文件夹不存在则创建
if [ ! -d "/data/" ];then
mkdir /data
else
echo "文件夹已经存在"
fi

文件存在则删除
if [ ! -f "/data/filename" ];then
echo "文件不存在"
else
rm -f /data/filename
fi

判断文件夹是否存在
if [ -d "/data/" ];then
     
echo "文件夹存在"
else
echo "文件夹不存在"
fi

判断文件是否存在
if [ -f "/data/filename" ];then
echo "文件存在"
else
echo "文件不存在"
fi

文件比较符
-e 判断对象是否存在
-d 判断对象是否存在，并且为目录
-f 判断对象是否存在，并且为常规文件
-L 判断对象是否存在，并且为符号链接
-h 判断对象是否存在，并且为软链接
-s 判断对象是否存在，并且长度不为0
-r 判断对象是否存在，并且可读
-w 判断对象是否存在，并且可写
-x 判断对象是否存在，并且可执行
-O 判断对象是否存在，并且属于当前用户
-G 判断对象是否存在，并且属于当前用户组
-nt 判断file1是否比file2新  [ "/data/file1" -nt "/data/file2" ]
-ot 判断file1是否比file2旧  [ "/data/file1" -ot "/data/file2" ]

```

## 使用grep查看进程

ps -ef | grep python

## nohub 将输出的日志写到文件中

```
nohup bash enen.sh >> server.log 2>&1 &

>> 代表能够追加显示   通过这个语句可以将日志信息完全显示到
```


## 压缩

```
tar -zcvf /home/xahot.tar.gz /xahot 
```
