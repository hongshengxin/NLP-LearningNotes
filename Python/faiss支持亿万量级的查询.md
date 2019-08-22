
[faiss简介及示例](https://blog.csdn.net/kanbuqinghuanyizhang/article/details/80774609)

##简介
faiss是为稠密向量提供高效相似度搜索和聚类的框架。由Facebook AI Research研发。 具有以下特性。

1、提供多种检索方法

2、速度快

3、可存在内存和磁盘中

4、C++实现，提供Python封装调用。

5、大部分算法支持GPU实现

```

import numpy as np
d = 64                              # 向量维度
nb = 100000                         # 向量集大小
nq = 10000                          # 查询次数
np.random.seed(1234)                # 随机种子,使结果可复现
xb = np.random.random((nb, d)).astype('float32')
xb[:, 0] += np.arange(nb) / 1000.
xq = np.random.random((nq, d)).astype('float32')
xq[:, 0] += np.arange(nq) / 1000.
 
import faiss
index=faiss.IndexFlatL2(d)
print(index.is_trained)
index.add(xb)
print(index.ntotal)

k=4
D,I=index.search(xb[:5],k)
print(xb[:5])
print(I)
print(D)
print("*"*20)
D,I=index.search(xq,k)
print(I[:5])


[[    0 83095 19619 83117]   # I 最近邻的索引
 [    1 35088 46180 23080]
 [    2 54374 53702 44158]
 [    3 70754 26592 37086]
 [    4 71223 55895 89119]]
[[0.        4.972082  5.0907245 5.119806 ]   #最近邻的距离参数  D
 [0.        4.9109025 5.3753996 5.427081 ]
 [0.        5.3356967 5.411192  5.4919424]
 [0.        5.289815  5.3254538 5.379574 ]
 [0.        5.1785083 5.19102   5.315337 ]]
********************
[[  17   22   19    7]  #index
 [ 477 1133  947  435]
 [   5   26   16    4]
 [  69  279   82   57]
 [  29   69   57    5]]
[[33277 42490 39935  3577]  
 [  507  1019   508   506]
 [ 7673 15356 12287  2044]
 [ 2555  4095  3582  2046]
 [ 1530  3577  3066   506]]
 
 索引取最合适的应该取top5等
```


##[更快的搜索 - IndexIVFFlat](https://blog.csdn.net/weixin_33711647/article/details/87003653)

```


```

