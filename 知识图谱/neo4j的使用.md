
#[史上超全面的Neo4j使用指南](https://www.javazhiyin.com/4602.html)

##neo4j的安装与入门

1，通过控制台启动Neo4j程序

点击组合键：Windows+R，输入cmd，启动DOS命令行窗口，切换到主目录，以管理员身份运行命令：
neo4j.bat console
2，把Neo4j安装为服务（Windows Services）

安装和卸载服务：
bin\neo4j install-service

bin\neo4j uninstall-service

启动服务，停止服务，重启服务和查询服务的状态：

bin\neo4j start

bin\neo4j stop

bin\neo4j restart

bin\neo4j status

## 节点的增删改查
```
create (p:pig{name:"猪爸爸",age=4})-[r:夫妻]->(p2:pig{name:"猪妈妈",age=4})

match (n:pig)  return n   这样将返回所有的pig节点

match (n:pig{name:"猪奶奶"}) return n  返回一个节点

match (n:pig) where n.name="猪奶奶" return n  返回一个节点

MATCH (n:BC_Person)-[r]-() DELETE n,r (删除节点，以及与之相关的所有关系)

match path=(p:pig)-[]-() return path  

match path=(p:pig)-[r:夫妻]-() return path  匹配某种关系的节点
match path=(p:pig)-[r:夫妻]-({name:"乔治"}) return path   取出和乔治是夫妻关系的节点
 ```
 
 ## [neo4j的批量导入](https://blog.csdn.net/qq_32519415/article/details/87942379)
 
 # cpyther 方法导入[链接](https://blog.csdn.net/sushaning/article/details/86024935)
 
 
亲自排坑啊~~~~

* 第一种方法导入load-CSV

```
1. 首先要将文件放到neo4j的import文件夹内
2. 第一种，带有标题的，你的数据文件必须要带标题
LOAD CSV with Headers FROM 
'file:///actors.csv' AS line with line
create (a:actors{personId:line.personId,name:line.name,type:line.LABEL})

第二种，不带标题的  你的数据文件也不需要带标题
USING PERIODIC COMMIT 10
LOAD CSV  FROM 
'file:///actors.csv' AS line with line
create (a:actors{personId:line[0],name:line[1],type:line[2]})

```
* [第二种方法用neo4j-import](https://blog.csdn.net/sinat_26917383/article/details/82424508)

```
使用条件
graph.db需要清空；
neo4j需要停掉；
接受CSV导入，而且格式较为固定；
试用场景:首次导入
节点名字需要唯一
```



## [python 连接neo4j，实现增删改查](https://blog.csdn.net/hhtnan/article/details/81742103)


```python
# node_1_zhangfu_node_1 = Relationship(test_node_1, '丈夫', test_node_2)
# node_1_zhangfu_node_1['count'] = 1
# node_2_qizi_node_1 = Relationship(test_node_2, '妻子', test_node_1)
# node_2_munv_node_1 = Relationship(test_node_2, '母女', test_node_3)
#
# node_2_qizi_node_1['count'] = 1
#
# graph.create(node_1_zhangfu_node_1)
# graph.create(node_2_qizi_node_1)
# graph.create(node_2_munv_node_1)
# data1 = graph.run('MATCH(p:pig) return p').data()
# print("data1 = ", data1, type(data1))
# print(graph.nodes.match("pig",name="佩奇").first())


```
* [通过标签和属性简单查找：NodeMatcher(graph).match()](https://www.jianshu.com/p/da84712ef62b)
```

```

##neo4j 建立多个数据库的方法

在conf文件内，将默认的数据库文件修改为其他数据库文件即可


