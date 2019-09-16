
分布式原理。分布式集群 由多个服务器进程、客户端进程组成。部署方式，单机多卡、分布式(多机多卡)。多机多卡TensorFlow分布式。

## 单机多卡

单机多卡，单台服务器多块GPU。训练过程：在单机单GPU训练，数据一个批次(batch)一个批次训练。单机多GPU，一次处理多个批次数据，每个GPU处理一个批次数据计算。变量参数保存在CPU，数据由CPU分发给多个GPU，GPU计算每个批次更新梯度。CPU收集完多个GPU更新梯度，计算平均梯度，更新参数。继续计算更新梯度。处理速度取决最慢GPU速度。

## 分布式
分布式，训练在多个工作节点(worker)。工作节点，实现计算单元。计算服务器单卡，指服务器。计算服务器多卡，多个GPU划分多个工作节点。数据量大，超过一台机器处理能力，须用分布式。
分布式TensorFlow底层通信，gRPC(google remote procedure call)。gRPC，谷歌开源高性能、跨语言RPC框架。RPC协议，远程过程调用协议，网络从远程计算机程度请求服务。


```python
def average_gradients(tower_grads):
  """Calculate the average gradient for each shared variable across all towers.
  Note that this function provides a synchronization point across all towers.
  Args:
    tower_grads: List of lists of (gradient, variable) tuples. The outer list
      is over individual gradients. The inner list is over the gradient
      calculation for each tower.
  Returns:
     List of pairs of (gradient, variable) where the gradient has been averaged
     across all towers.
  """
  average_grads = []
  for grad_and_vars in zip(*tower_grads):
    # Note that each grad_and_vars looks like the following:
    #   ((grad0_gpu0, var0_gpu0), ... , (grad0_gpuN, var0_gpuN))
    grads = []
    for g, _ in grad_and_vars:
      # Add 0 dimension to the gradients to represent the tower.
      expanded_g = tf.expand_dims(g, 0)

      # Append on a 'tower' dimension which we will average over below.
      grads.append(expanded_g)

    # Average over the 'tower' dimension.
    grad = tf.concat(axis=0, values=grads)
    grad = tf.reduce_mean(grad, 0)

    # Keep in mind that the Variables are redundant because they are shared
    # across towers. So .. we will just return the first tower's pointer to
    # the Variable.
    v = grad_and_vars[0][1]
    grad_and_var = (grad, v)
    average_grads.append(grad_and_var)
  return average_grads

```