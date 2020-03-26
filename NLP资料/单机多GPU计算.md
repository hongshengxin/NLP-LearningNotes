```python
"""
演示多GPU使用
"""
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
import cv2
import numpy as np
import os
import matplotlib.pyplot as plt


FLAGS = tf.app.flags.FLAGS

tf.app.flags.DEFINE_integer('batch_size', 128,
                            """Number of images to process in a batch.""")
tf.app.flags.DEFINE_string('checkpoint_dir', './models/cpu_gpu/checkpoints',
                           "模型持久化保存路径")
tf.app.flags.DEFINE_string('graph_dir', './models/cpu_gpu/graph',
                           "模型可视化保存路径")

def _variable_on_cpu(name, shape, initilizer=tf.truncated_normal_initializer(stddev=0.1)):
    """
    再cpu上创建变量
    :param name:
    :param shape:
    :param initilizer:
    :return:
    """
    with tf.device('/cpu:0'):
        var = tf.get_variable(name, shape, initializer=initilizer, dtype=tf.float32)
    return var


class Tensors:
    """
    构建模型图的类
    """
    def __init__(self, gpus):
        self.x_s = []
        self.y_s = []
        self.grads_and_vars_s = []
        self.loss_s = []
        self.predict_s = []
        self.precise_s = []

        self.keep_prob = tf.placeholder(tf.float32, name='keep_prob')
        self.lr = tf.placeholder(tf.float32, name='lr')

        # 有几个gpu,就有几个模型，但是这些模型的权重都是共享。
        with tf.variable_scope('Network'):
            self.optimizer_s = tf.train.GradientDescentOptimizer(self.lr)
            for gpu_idx in range(gpus):
                with tf.device('/gpu:{}'.format(gpu_idx)):
                    x = tf.placeholder(tf.float32, [None, 784], name='x')
                    y = tf.placeholder(tf.int32, [None], name='y')
                    # 因为x 和y 占位符不能共享，所以将其追加到列表中
                    self.x_s.append(x)
                    self.y_s.append(y)

                    x = tf.reshape(x, shape=[-1, 28, 28, 1])

                    # 卷积1
                    with tf.variable_scope('conv1') as scope:
                        # todo 卷积核参数w 是再cpu上创建的，但是权重计算是再相应的gpu上计算的
                        weights = _variable_on_cpu('w', shape=[3, 3, 1, 32])
                        biases = _variable_on_cpu('b', shape=[32], initilizer=tf.zeros_initializer())
                        conv1 = tf.nn.conv2d(x, weights, [1,1,1,1], padding='SAME')
                        conv1 = tf.nn.bias_add(conv1, biases)
                        conv1 = tf.nn.relu6(conv1, name=scope.name)
                        # [N, 28, 28, 32]

                    # 池化1
                    pool1 = tf.layers.max_pooling2d(conv1, 2, 2, padding='same', name='pool1')

                    # 卷积2
                    with tf.variable_scope('conv2') as scope:
                        # todo 卷积核参数w 是再cpu上创建的，但是权重计算是再相应的gpu上计算的
                        weights = _variable_on_cpu('w', shape=[3, 3, 32, 64])
                        biases = _variable_on_cpu('b', shape=[64], initilizer=tf.zeros_initializer())
                        conv2 = tf.nn.conv2d(pool1, weights, [1,1,1,1], padding='SAME')
                        conv2 = tf.nn.bias_add(conv2, biases)
                        conv2 = tf.nn.relu6(conv2, name=scope.name)
                        # [N, 14, 14, 64]

                    # 池化2
                    pool2 = tf.layers.max_pooling2d(conv2, 2, 2, padding='same', name='pool2')
                    # [N, 7, 7, 64]

                    # 全连接层
                    with tf.variable_scope('fc1') as scope:
                        fc1 = tf.reshape(pool2, shape=[-1, 7*7*64])
                        weights = _variable_on_cpu('w', shape=[7*7*64, 512])
                        biases = _variable_on_cpu('b', shape=[512], initilizer=tf.zeros_initializer())

                        fc1 = tf.nn.xw_plus_b(fc1, weights, biases)
                        fc1 = tf.nn.relu6(fc1)
                        fc1 = tf.nn.dropout(fc1, keep_prob=self.keep_prob)

                    # 全连接层
                    with tf.variable_scope('logits') as scope:
                        weights = _variable_on_cpu('w', shape=[512, 10])
                        biases = _variable_on_cpu('b', shape=[10], initilizer=tf.zeros_initializer())

                        logits = tf.nn.xw_plus_b(fc1, weights, biases)

                    # 求模型损失
                    loss = tf.reduce_mean(tf.nn.sparse_softmax_cross_entropy_with_logits(
                        labels=y, logits=logits
                    ))
                    self.loss_s.append(loss)  # 每个gpu计算出来的损失是不一样的，所以追加到一个列表中去

                    # 计算梯度值
                    grads_and_vars = self.optimizer_s.compute_gradients(loss)
                    self.grads_and_vars_s.append(grads_and_vars)
                    self.predict_s.append(tf.nn.softmax(logits))

                    # 计算准确率
                    correct_pred = tf.equal(tf.cast(
                        tf.argmax(self.predict_s[-1], axis=1), tf.int32), y)
                    accuracy = tf.reduce_mean(tf.cast(correct_pred, tf.float32))
                    self.precise_s.append(accuracy)

                    # todo 重用所有当前的变量
                    tf.get_variable_scope().reuse_variables()

        # 计算平均梯度值
        with tf.device('/cpu:0'):
            var_grads = self.compute_vars_grads()
            grads_and_vars_new = [
                (tf.reduce_mean(var_grads[v], axis=0), v) for v in var_grads
            ]
            self.train_opt = self.optimizer_s.apply_gradients(grads_and_vars_new)  # 执行梯度下降

        # 计算损失
        self.loss = tf.reduce_mean(self.loss_s)

    def compute_vars_grads(self):
        rezult = {}
        for grad_and_var in self.grads_and_vars_s:
            for g, v in grad_and_var:
                if v not in rezult:
                    rezult[v] = []
                rezult[v].append(g)
        return rezult


class Mnist:
    """
    执行会话的类，执行模型训练
    """
    def __init__(self, gpus):
        self.graph = tf.Graph()
        self.gpus = gpus
        self.lr = 1e-3
        self.checkpoint_dir = FLAGS.checkpoint_dir
        if not os.path.exists(self.checkpoint_dir):
            os.makedirs(self.checkpoint_dir)

        # 调用tensor类 构建模型图
        with self.graph.as_default():
            self.tensors = Tensors(self.gpus)

            config = tf.ConfigProto(allow_soft_placement=True)
            self.sess = tf.Session(config=config, graph=self.graph)
            self.saver = tf.train.Saver()

            # 恢复模型
            ckpt = tf.train.get_checkpoint_state(self.checkpoint_dir)
            if ckpt and ckpt.model_checkpoint_path:
                self.saver.restore(self.sess, ckpt.model_checkpoint_path)
                print('恢复模型')
            else:
                self.sess.run(tf.global_variables_initializer())
                print('随机初始化模型变量')

    def train(self, batch_size=32, epochs=5):
        self.batch_size = batch_size
        self.epochs = epochs

        data = input_data.read_data_sets('../datas/mnist')

        # 多了一个gpus数量，所以我们每一个steps 需要除以  batch_size * gpus
        n_batches = data.train.num_examples // (self.batch_size * self.gpus)

        for e in range(self.epochs):
            for step in range(n_batches):
                feed = {self.tensors.lr: self.lr, self.tensors.keep_prob: 0.6}

                # 循环喂入数据
                for i in range(self.gpus):
                    images, labels = data.train.next_batch(self.batch_size)
                    feed[self.tensors.x_s[i]] = images
                    feed[self.tensors.y_s[i]] = labels
                # 执行模型训练
                _, loss = self.sess.run([self.tensors.train_opt, self.tensors.loss], feed)
                print('Epochs:{} - Train Loss:{}'.format(e, loss))

            # 跑验证数据
            feed_dict = {
                self.tensors.keep_prob: 1.0
            }
            for i in range(self.gpus):  # 分别在不同gpu上做验证计算
                imgs, labels = data.validation.next_batch(batch_size)
                feed_dict[self.tensors.x_s[i]] = imgs
                feed_dict[self.tensors.y_s[i]] = labels
            precise_s = self.sess.run(self.tensors.precise_s, feed_dict)
            precise = np.mean(precise_s)

            print('{}/{},,precise = {:.4f}'.format(step, epochs, precise))

            if (step + 1) % 20 == 0:
                file_name = 'model_{:.3f}_.ckpt'.format(precise)
                save_file = os.path.join(self.checkpoint_dir, file_name)
                self.saver.save(self.sess, save_file, global_step=step)

    def test(self, batch_size=512):
        data = input_data.read_data_sets("../datas/mnist")
        steps = data.test.num_examples // (batch_size * self.gpus)

        precise, n = 0.0, 0
        for step in range(steps):
            feed_dict = {
                self.tensors.keep_prob: 1.0
            }

            label_s = []
            for i in range(self.gpus):
                imgs, labels = data.test.next_batch(batch_size)
                label_s.append(labels)
                feed_dict[self.tensors.x_s[i]] = imgs
            pred_s = self.sess.run(self.tensors.predict_s, feed_dict)
            # 手动求测试集准确率。
            for i, pred in enumerate(pred_s):
                pred = np.argmax(pred, axis=1)
                precise += np.mean(np.float32(np.equal(pred, label_s[i])))
                n += 1
        print('precise:{}'.format(precise/n))


def main(_):
    opt = 0
    if opt == 0:
        mnist = Mnist(gpus=2)
        mnist.train(batch_size=128, epochs=5)
    else:
        mnist = Mnist(gpus=2)
        mnist.test(batch_size=128)



if __name__ == '__main__':
    tf.app.run()
```