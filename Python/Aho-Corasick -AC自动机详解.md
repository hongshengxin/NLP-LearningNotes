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

　　1.建立模式的Trie树

    Trie树也是一种自动机。对于多模式集合{"say","she","shr","he","her"}，
    对应的Trie树如下，其中红色标记的圈是表示为接收态：

![trie树](https://images0.cnblogs.com/blog/466768/201311/20142042-7e12ab062d514f9798f679becfb91914.jpg)

　　2.给Trie添加失败路径

    构造失败指针的过程概括起来就一句话：设这个节点上的字母为C，沿着他父亲的失败指针走，直到走到一个节点，他的儿子中也有字母为C的节点。然后把当前节点的失败指针指向那个字母也为C的儿子。如果一直走到了root都没找到，那就把失败指针指向root。
    使用广度优先搜索BFS，层次遍历节点来处理，每一个节点的失败路径

![](https://images0.cnblogs.com/blog/466768/201311/20142122-959c9e41d1e94d55b36060275d2ce7db.jpg)

　　3.根据AC自动机，搜索待处理的文本

    从root节点开始，每次根据读入的字符沿着自动机向下移动。当读入的字符，在分支中不存在时，递归走失败路径。如果走失败路径走到了root节点，则跳过该字符，处理下一个字符。
    因为AC自动机是沿着输入文本的最长后缀移动的，所以在读取完所有输入文本后，最后递归走失败路径，直到到达根节点，这样可以检测出所有的模式

### 2.安装方法

　　1.windows 安装方法

    在windows安装这种复杂的计算包，是很麻烦，经常碰到需要C++14等情况，踩过很多坑，在这分享一种一次安装成功的方法
    conda install -c https://conda.anaconda.org/conda-forge pyahocorasick
    最后输入y，就安装完成了
    
    需要等好一会的~~~~~  所以做一个好的算法工程师不要用windows,不要用windows
    
   2.linux 安装方法
    
    pip 就行啦    
    
### 3. 使用方法
```
import ahocorasick
'''构建领域话术'''
def build_actree(wordlist):
    actree = ahocorasick.Automaton()
    for index, word in enumerate(wordlist):
        actree.add_word(word, (index, word))
    actree.make_automaton()
    return actree

actree=build_actree(region_list)
result_dict=classify(actree,text)
```
![使用方法](JPG/2.PNG)





    


