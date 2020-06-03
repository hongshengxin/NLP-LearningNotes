

# batchNormalization与layerNormalization的区别

###区别：
Batch Normalization 的处理对象是对一批样本， Layer Normalization 的处理对象是单个样本。
Batch Normalization 是对这批样本的同一维度特征做归一化， Layer Normalization 是对这单个样本的所有维度特征做归一化。

```python

def batch_normalization(batch, mean=None, var=None):
    if mean is None or var is None:
        mean, var = tf.nn.moments(batch, axes=[0])
    return (batch - mean) / tf.sqrt(var + tf.constant(1e-10))

```


```python

fc = tf.layers.dense(input, output, activation = None)
fc = tf.layers.batch_normalization(fc, training=training)
fc = tf.nn.relu(fc)
#...
with tf.control_dependencies(tf.get_collection(tf.GraphKeys.UPDATE_OPS)):#用于更新moving_mean和moving_variance
      train_op = tf.train.AdamOptimizer(learning_rate).minimize(loss)
```


```python
fc = tf.layers.dense(input, output, activation = None)
fc = tf.contrib.layers.layer_norm(fc)
fc = tf.nn.relu(fc)
#...
train_op = tf.train.AdamOptimizer(learning_rate).minimize(loss)

```


[https://zhuanlan.zhihu.com/p/54530247]