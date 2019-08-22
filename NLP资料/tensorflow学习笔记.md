
## 1.学习率设置指数衰减法

```
learning_rate = tf.train.exponential_decay(0.1,global_step,100,0.96,staircase=True)


其中，decayed_learning_rate ------当前衰减过后的学习率

learning_rate ----- 初始学习率

decay_rate ----- 衰减系数

global_step / decay_steps  控制衰减的速度，其中decay_steps 是一个人为指定的常量，
而global_step 则是从0开始慢慢加上去的一个变量 ，
因此 global_step / decay_steps 便会随着迭代慢慢变大，使得学习率衰减的程度变得越来越大。
```

###两种方法：

* 动态传参
```
from numpy.random import RandomState
import numpy as np

batch_size=8


learning_rate = 0.1

with tf.name_scope("sdfsd"):
    groable=tf.Variable(tf.constant(0))
    lrate=tf.train.exponential_decay(learning_rate,groable,100,0.89)
    mini = tf.train.AdamOptimizer(learning_rate=lrate).minimize(loss)
c = []

STEP = 1000
with tf.Session() as sess:
    sess.run(tf.global_variables_initializer())
    for i in range(STEP):
        start = (i * batch_size) % dataset_size
        end = min(start + batch_size, dataset_size)
        lr,_= sess.run((lrate,mini), feed_dict={groable: i, x: X[start:end], y: Y[start:end]})
        c.append(lr)
        print("steps {}的学习率为{}".format(i, lr))

```
* minimize 传参
```
mini = tf.train.AdamOptimizer(learning_rate=lrate).minimize(loss,global_step=groable)
```
## [TensorFlow报错Fetch argument None has invalid type class 'NoneType'](https://blog.csdn.net/qq_41000891/article/details/84555225)


##TensorFlow 模型保存/载入的两种方法
```
模型保存，根据globalstep进行保存
saver.save(sess, 'my-model', global_step=0) ==> filename: 'my-model-0'
...
saver.save(sess, 'my-model', global_step=1000) ==> filename: 'my-model-1000'

```

## tf.estimator.Estimator类的用法[链接](https://www.cnblogs.com/zongfa/p/10149483.html)
```

```

