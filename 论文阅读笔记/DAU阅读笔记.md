

## 1. 建立了第一个电子商务的多轮对话数据集，来验证这个问题

## 2. 采用的方法

1.对之前多轮对话的内容进行了权重分析，
2.并且在多个转折场景中，根据话语本身的每个词，从每个话语中积累了大量的部分。
3.对于每句话中的不同的单词，采用网络结构，得到句子的表征

## 3.Deep Utterance Aggregating Strategy  深层次语义聚合策略

```

Specifically, there are five modules
within DUA. Each utterance or response is fed to the first module to form an utterance or response
embedding. The second module combines the last utterance with the preceding utterances. Then, the
third module filters the redundant information and mines the salient feature within the utterances and
response. The fourth module matches the response and each utterance at both word and utterance levels
to feed a Convolutional Neural Network (CNN) for encoding into matching vectors. In the last module,
the matching vectors are delivered to a gated recurrent unit (GRU) (Cho et al., 2014) in chronological
order of the utterances in the context and the final matching score of fU;Rg is obtained.


具体来说，有五个模块

在DUA内。每个话语或响应被送入第一个模块以形成话语或响应。

嵌入。第二个模块将最后一句话和前面的话结合起来。然后，

第三个模块过滤冗余信息，挖掘语音中的显著特征

回答。第四个模块在单词和发音级别匹配响应和每个发音。

将卷积神经网络（CNN）编码到匹配向量中。在最后一个模块中，

匹配向量按时间顺序发送到选通循环单元（GRU）（Cho等人，2014年）。

得到了在语境中的话语顺序和Fu；rg的最终匹配分数
```