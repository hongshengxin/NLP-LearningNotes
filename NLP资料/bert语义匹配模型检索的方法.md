

首先通过BM 25选出10句话作为候选句子，然后去根据consine距离求解最大值的句子

```python
scores = [1 - spatial.distance.cosine(result, candi_sentence) for candi_sentence in query_result]

```
