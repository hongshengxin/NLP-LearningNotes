#详解Transformer （Attention Is All You Need）

##前言

正如论文的题目所说的，Transformer中抛弃了传统的CNN和RNN，整个网络结构完全是由Attention机制组成。
更准确地讲，Transformer由且仅由self-Attenion和Feed Forward Neural Network组成。
一个基于Transformer的可训练的神经网络可以通过堆叠Transformer的形式进行搭建，
作者的实验是通过搭建编码器和解码器各6层，总共12层的Encoder-Decoder，
并在机器翻译中取得了BLEU值得新高。

作者采用Attention机制的原因是考虑到RNN（或者LSTM，GRU等）的计算限制为是顺序的，也就是说RNN相关算法只能从左向右依次计算或者从右向左依次计算，这种机制带来了两个问题：

* 时间片 t 的计算依赖t-1时刻的计算结果，这样限制了模型的并行能力；
* 顺序计算的过程中信息会丢失，尽管LSTM等门机制的结构一定程度上缓解了长期依赖的问题，但是对于特别长期的依赖现象,LSTM依旧无能为力。

Transformer的提出解决了上面两个问题，首先它使用了Attention机制，将序列中的任意两个位置之间的距离是缩小为一个常量；其次它不是类似RNN的顺序结构，因此具有更好的并行性，符合现有的GPU框架。论文中给出Transformer的定义是：Transformer is the first transduction model relying entirely on self-attention to compute representations of its input and output without using sequence aligned RNNs or convolution。

遗憾的是，作者的论文比较难懂，尤其是Transformer的结构细节和实现方式并没有解释清楚。尤其是论文中的 Q ， V ， K 究竟代表什么意思作者并没有说明。通过查阅资料，发现了一篇非常优秀的讲解Transformer的技术博客[4]。本文中的大量插图也会从该博客中截取。首先感谢Jay Alammer详细的讲解，其次推荐大家去阅读原汁原味的文章。