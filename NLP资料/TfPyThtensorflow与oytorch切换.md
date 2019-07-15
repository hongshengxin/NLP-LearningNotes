##一行代码切换TensorFlow与PyTorch，模型训练也能用俩框架

在早两天开源的 TfPyTh 中，不论是 TensorFlow 还是 PyTorch 计算图，它们都可以包装成一个可微函数，
并在另一个框架中高效完成前向与反向传播。很显然，这样的框架交互，能节省很多重写代码的麻烦事。

项目地址：https://github.com/BlackHC/TfPyTh

##TfPyTh 示例
```
import tensorflow as tf
import torch as th
import numpy as np
import tfpyth

session = tf.Session()
def get_torch_function():
    a = tf.placeholder(tf.float32, name='a')
    b = tf.placeholder(tf.float32, name='b')
    c = 3 * a + 4 * b * b

    f = tfpyth.torch_from_tensorflow(session, [a, b], c).apply
    return f

f = get_torch_function()
a = th.tensor(1, dtype=th.float32, requires_grad=True)
b = th.tensor(3, dtype=th.float32, requires_grad=True)
x = f(a, b)
assert x == 39.

x.backward()
assert np.allclose((a.grad, b.grad), (3., 24.))

```