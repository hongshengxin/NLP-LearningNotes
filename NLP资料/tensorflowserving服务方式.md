

# Tensorflow serving使用教程


## 一. tensorflow代码实现serving方法

### 1. 将模型保存为pb文件，tensorflow serving支持pb模型的文件

* 使用tensorflow  SaveModelBuilder 方式

```

export_path_base = sys.argv[-1]
export_path = os.path.join(
      compat.as_bytes(export_path_base),
      compat.as_bytes(str(FLAGS.model_version)))
print('Exporting trained model to', export_path)
builder = tf.saved_model.builder.SavedModelBuilder(export_path)
builder.add_meta_graph_and_variables(
      sess, [tf.saved_model.tag_constants.SERVING],
      signature_def_map={
           'predict_images':
               prediction_signature,
           signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY:
               classification_signature,
      },
      main_op=tf.tables_initializer())
builder.save()
```

### 2. [这得详细说一下tf.save_model.builder这个方法了](https://blog.csdn.net/thriving_fcl/article/details/75213361)

saved_model模块主要用于TensorFlow Serving。TF Serving是一个将训练好的模型部署至生产环境的系统，
主要的优点在于可以保持Server端与API不变的情况下，部署新的算法或进行试验，同时还有很高的性能。


1. 仅用Saver来保存/载入变量。这个方法显然不行，仅保存变量就必须在inference的时候重新定义Graph(定义模型)，这样不同的模型代码肯定要修改。即使同一种模型，参数变化了，也需要在代码中有所体现，至少需要一个配置文件来同步，这样就很繁琐了。
2. 使用tf.train.import_meta_graph导入graph信息并创建Saver， 再使用Saver restore变量。相比第一种，不需要重新定义模型，但是为了从graph中找到输入输出的tensor，还是得用graph.get_tensor_by_name()来获取，也就是还需要知道在定义模型阶段所赋予这些tensor的名字。如果创建各模型的代码都是同一个人完成的，还相对好控制，强制这些输入输出的命名都一致即可。如果是不同的开发者，要在创建模型阶段就强制tensor的命名一致就比较困难了。这样就不得不再维护一个配置文件，将需要获取的tensor名称写入，然后从配置文件中读取该参数。

* 保存
```
builder = tf.saved_model.builder.SavedModelBuilder(saved_model_dir)
builder.add_meta_graph_and_variables(sess, ['tag_string'])
builder.save()
```
* 载入

```
使用tf.saved_model.loader.load方法就可以载入模型。如

meta_graph_def = tf.saved_model.loader.load(sess, ['tag_string'], saved_model_dir)
1
第一个参数就是当前的session，第二个参数是在保存的时候定义的meta graph的标签，标签一致才能找到对应的meta graph。第三个参数就是模型保存的目录。

load完以后，也是从sess对应的graph中获取需要的tensor来inference。如

x = sess.graph.get_tensor_by_name('input_x:0')
y = sess.graph.get_tensor_by_name('predict_y:0')

# 实际的待inference的样本
_x = ... 
sess.run(y, feed_dict={x: _x})
1
2
3
4
5
6
```


* 使用SignatureDef

关于SignatureDef我的理解是，它定义了一些协议，对我们所需的信息进行封装，我们根据这套协议来获取信息，
从而实现创建与使用模型的解耦,创建相关输入输出变量的映射关系，并且能够支持C++和Python两种方法.

相关API
```
# 构建signature
tf.saved_model.signature_def_utils.build_signature_def(
    inputs=None,
    outputs=None,
    method_name=None
)
# 构建tensor info 

tf.saved_model.utils.build_tensor_info(tensor)
```

* 保存
```

builder = tf.saved_model.builder.SavedModelBuilder(saved_model_dir)
# x 为输入tensor, keep_prob为dropout的prob tensor 
inputs = {'input_x': tf.saved_model.utils.build_tensor_info(x), 
            'keep_prob': tf.saved_model.utils.build_tensor_info(keep_prob)}

# y 为最终需要的输出结果tensor 
outputs = {'output' : tf.saved_model.utils.build_tensor_info(y)}

signature = tf.saved_model.signature_def_utils.build_signature_def(inputs, outputs, 'test_sig_name')

builder.add_meta_graph_and_variables(sess, ['test_saved_model'], {'test_signature':signature})
builder.save()



上述inputs增加一个keep_prob是为了说明inputs可以有多个， build_tensor_info方法将tensor相关的信息序列化为TensorInfo protocol buffer。

inputs，outputs都是dict，key是我们约定的输入输出别名，value就是对具体tensor包装得到的TensorInfo。

然后使用build_signature_def方法构建SignatureDef，第三个参数method_name暂时先随便给一个。

创建好的SignatureDef是用在add_meta_graph_and_variables的第三个参数signature_def_map中，但不是直接传入SignatureDef对象。事实上signature_def_map接收的是一个dict，key是我们自己命名的signature名称，value是SignatureDef对象。

```

* 载入
```
## 略去构建sess的代码

signature_key = 'test_signature'
input_key = 'input_x'
output_key = 'output'

meta_graph_def = tf.saved_model.loader.load(sess, ['test_saved_model'], saved_model_dir)
# 从meta_graph_def中取出SignatureDef对象
signature = meta_graph_def.signature_def

# 从signature中找出具体输入输出的tensor name 
x_tensor_name = signature[signature_key].inputs[input_key].name
y_tensor_name = signature[signature_key].outputs[output_key].name

# 获取tensor 并inference
x = sess.graph.get_tensor_by_name(x_tensor_name)
y = sess.graph.get_tensor_by_name(y_tensor_name)

# _x 实际输入待inference的data
sess.run(y, feed_dict={x:_x})

```

## 2. 使用docker 部署环境

port端口的区别：

8501：restfull 模式
8500：grpc 模式

```
docker run -p 8500:8500 \
--mount type=bind,source=/tmp/mnist,target=/models/mnist \
-e MODEL_NAME=mnist -t tensorflow/serving &

```

## 移动端的测试脚本

```
import requests
    from time import time

    import numpy as np

    url = 'http://localhost:8501/v1/models/pb_model:predict'

    sentence = "on a cutting room floor somewhere lies . . . footage that might have made no such thing a trenchant , ironic cultural satire instead of a frustrating misfire"
    sentence = vocab_processor.fit_transform([sentence])
    # sentence=np.array(sentence)
    new_sentence = list(sentence)
    new_sentence = new_sentence[0].tolist()

    predict_request = '{"instances" : [{"input": %s,"keep_prob":0.5}]}' % list(new_sentence)  # 一定要list才能传输，不然json错误

    print("start")
    start_time = time()
    r = requests.post(url, data=predict_request)
    print(r.content)
    end_time = time()

```


### 相关教程连接

[教程1](https://www.jianshu.com/p/d11a5c3dc757)