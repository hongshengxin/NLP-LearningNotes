##楼主吐血整理了pytorch的19种损失函数，学会后吊打面试官
损失函数在pytorch中是在torch.nn包实现的，可以自己实现和调包

### 1.自己实现

```python
criterion = LossCriterion() #构造函数有自己的参数
loss = criterion(x, y) #调用标准时也有参数
```

### 2.调包侠的必备

* L1Loss

