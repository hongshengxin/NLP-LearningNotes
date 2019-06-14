##Aho-Corasick 多模式匹配算法、AC自动机详解

&ensp;&ensp;Aho-Corasick算法是多模式匹配中的经典算法，目前在实际应用中较多。个人就在对话系统，知识图谱等实际工程
应用到，不过踩过很多坑，现在与大家分享下

### 1.原理介绍
&ensp;&ensp;Aho-Corasick算法对应的数据结构是Aho-Corasick自动机，简称AC自动机,原理晦涩难懂，原理晦涩难懂~~~

- 多模式匹配

  多模式匹配就是有多个模式串P1,P2,P3...，Pm，
求出所有这些模式串在连续文本T1....n中的所有可能出现的位置。
例如：求出模式集合{"nihao","hao","hs","hsr"}在给定文本"sdmfhsgnshejfgnihaofhsrnihao"
中所有可能出现的位置。
``个人理解可以参考np.find()方法,只不过find只返回一个结果``
- Aho-Corasick算法

　　使用Aho-Corasick算法需要三步：

　　1.建立模式的Trie

　　2.给Trie添加失败路径

　　3.根据AC自动机，搜索待处理的文本


    


