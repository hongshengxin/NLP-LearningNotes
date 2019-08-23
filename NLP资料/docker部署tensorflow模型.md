
##这个挖坑，埋坑，挖坑，埋坑的整理

### 1.部署tensorflow serving

反正我刚开始不会写docker镜像，那我就用别人已经做好的了


拉取带tensorflow serving的docker镜像，
这样我们服务器上就有了一个安装了ModelServer的docker容器, 
这个容器就可以看做一台虚拟机，这个虚拟机上已经安装好了tensorflow serving，环境有了，
就可以用它来部署我们的模型了。注意这个拉取下来后不是直接放在当前目录的，
而是docker默认存储的路径，这个是个docker容器，和第2步clone下来的不是同一个东西

```
$docker pull tensorflow/serving
```

###2、获取例子模型：
（当然，也可以直接用上面容器中自带的例子），当然这里是直接拉取了tensorflow serving的源码，源码中有一些训练好的例子模型
```
$cd /root/software/
$git clone https://github.com/tensorflow/serving
```

###3、用第一步拉取的docker容器运行例子模型

第2步中clone下来的serving源码中有这样一个训练好的例子模型，路径为：
```
/root/software/serving/tensorflow_serving/servables/tensorflow/testdata/saved_model_half_plus_two_cpu
```

现在我们就要用第1步拉下来的docker容器来运行部署这个例子模型,以一下命令去执行docker程序。

```
$docker run -p 8501:8501 \
  --mount type=bind,\
  source=/root/software/serving/tensorflow_serving/servables/tensorflow/testdata/saved_model_half_plus_two_cpu,\
  target=/models/half_plus_two \
  -e MODEL_NAME=half_plus_two -t tensorflow/serving &
```

参数说明：
```
--mount：   表示要进行挂载
source：    指定要运行部署的模型地址， 也就是挂载的源，这个是在宿主机上的模型目录
target:     这个是要挂载的目标位置，也就是挂载到docker容器中的哪个位置，这是docker容器中的目录
-t:         指定的是挂载到哪个容器
-p:         指定主机到docker容器的端口映射
docker run: 启动这个容器并启动模型服务（这里是如何同时启动容器中的模型服务的还不太清楚）
 
综合解释：
         将source目录中的例子模型，挂载到-t指定的docker容器中的target目录，并启动
```

###4、调用这个服务，这里用的http接口

```
$curl -d '{"instances": [1.0, 2.0, 5.0]}' \
  -X POST http://localhost:8501/v1/models/half_plus_two:predict
```

参数说明：

```
models/half_plus_two是docker挂载这个镜像的位置：predict是指的参数
```

###5、查看启动的这个模型的目录的结构

我们可以看到启动服务的命令有一个参数：

```
source=/root/software/serving/tensorflow_serving/servables/tensorflow/testdata/saved_model_half_plus_two_cpu
```
这实际就是模型的位置， 我们进入到这个目录下（这个目录基于自己pull时所在的目录），
可以看到里面是一个名为00000123的目录，
这实际是模型的版本，再进入到这个目录下可以看到一个如下两个文件：
```
saved_model.pb, variables
```
variable目录下有如下两个文件：
```
variables.data-00000-of-00001, variables.index
```
###6.用自己的模型替换上述half_plus_two模型

我在和saved_model_half_plus_two_cpu模型同级的目录下创建了一个文件夹，名为textcnnrnn， 这是我模型的名称，然后:
```
$cd textcnnrnn
$mkdir 00000123
$cd 00000123
$mkdir variables
$cd variables
我一开始是直接用的我之前训练好的模型放到了variables目录下，我训练好的模型包含如下几个文件：

best_validation.data-00000-of-00001  best_validation.index  best_validation.meta  checkpoint

```
相信大家都看出来了，这个是用这种方式保存的：
```
saver = tf.train.Saver()
saver.save(sess=session, save_path=save_path)

docker run -p 8501:8501 --mount source=/root/software/serving/tensorflow_serving/servables/tensorflow/testdata/textcnnrnn,type=bind,target=/models/find_lemma_category -e MODEL_NAME=find_lemma_category -t tensorflow/serving &
这样不对········
```
###7.将模型转为指定的格式

```
# coding: utf-8
 
from __future__ import print_function
import pdb
import time
import os
import tensorflow as tf
import tensorflow.contrib.keras as kr
 
from cnn_rnn_model import TCNNRNNConfig, TextCNNRNN
 
save_path = 'model_saver/textcnnrnn/best_validation'
try:
    bool(type(unicode))
except NameError:
    unicode = str
 
config = TCNNRNNConfig()
 
def build_and_saved_wdl():
 
    model = TextCNNRNN(config) #我自己的模型结构是在这个类中定义的，基于自己的模型进行替换
 
    session = tf.Session()
    session.run(tf.global_variables_initializer())
    saver = tf.train.Saver()
    saver.restore(sess=session, save_path=save_path)
 
   # 将训练好的模型保存在model_name下，版本为2，当然你的版本可以随便写
    builder = tf.saved_model.builder.SavedModelBuilder("./model_name/2")
    inputs = {
        #注意，这里是你预测模型的时候需要传的参数，调用模型的时候，传参必须和这里一致
        #这里的model.input_x和model.keep_prob就是模型里面定义的输入placeholder    
        "input_x": tf.saved_model.utils.build_tensor_info(model.input_x),
        "keep_prob": tf.saved_model.utils.build_tensor_info(model.keep_prob)
    }
 
    #model.y_pred_cls是模型的输出， 预测的时候就是计算这个表达式
    output = {"output": tf.saved_model.utils.build_tensor_info(model.y_pred_cls)}
    prediction_signature = tf.saved_model.signature_def_utils.build_signature_def(
        inputs=inputs,
        outputs=output,
        method_name=tf.saved_model.signature_constants.PREDICT_METHOD_NAME
    )
 
    builder.add_meta_graph_and_variables(
        session,
        [tf.saved_model.tag_constants.SERVING],
        {tf.saved_model.signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY: prediction_signature}
    )
    builder.save()
 
 
if __name__ == '__main__':
    build_and_saved_wdl()
```

执行后，会在当前目录下生成一个名称为./model_name/2的文件夹， 这个文件夹下的文件格式和halt_plus_two中的文件格式是一致的了，这下肯定没错了。

将./model_name/2文件夹下的内容拷贝到textcnnrnn/00000123目录下即可。

重新启动模型，这次启动成功了，没有报错，说明我们的模型已经被识别成功。

###7、调用模型

```
p_data = {"keep_prob": 1.0, "input_x": x_test[0]}
param = {"instances": [p_data]}
param = json.dumps(param, cls=NumpyEncoder)
res = requests.post('http://localhost:8501/v1/models/find_lemma_category:predict', data=param)
```
###8、参数要预处理怎么办？
假如我们需要在将参数输入模型之前做一些预处理怎么办？比如要对大段文本进行分词等等。

解决办法： 部署一个中转服务，我采用的策略是用tornado再部署一个服务，这个服务负责对业务方传输过来的参数进行预处理，处理成模型需要的格式后，再传输给模型， 所以我的结构是这样的：

业务方 ==>  tornado服务（参数预处理） ==> 模型(tensorflow serving服务)

这里面的两次远程调用都是http协议。


