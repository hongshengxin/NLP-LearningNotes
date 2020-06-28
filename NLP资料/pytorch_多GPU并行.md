# Pytorch多GPU并行运算练习

使用

```
#-*- coding:utf-8 -*-
import torch
from torch import nn,optim
from torch.autograd import Variable
import numpy as np
import matplotlib.pyplot as plt
import os

os.environ["CUDA_VISIBLE_DEVICES"] = "0,1"

x_train = np.array([[3.3], [4.4], [5.5], [6.71], [6.93], [4.168],
                    [9.779], [6.182], [7.59], [2.167], [7.042],
                    [10.791], [5.313], [7.997], [3.1]], dtype=np.float32)

y_train = np.array([[1.7], [2.76], [2.09], [3.19], [1.694], [1.573],
                    [3.366], [2.596], [2.53], [1.221], [2.827],
                    [3.465], [1.65], [2.904], [1.3]], dtype=np.float32)

x_train=torch.from_numpy(x_train)
y_train=torch.from_numpy(y_train)
USE_CUDA=1 if torch.cuda.is_available() else 0


device = torch.device("cuda:0" if USE_CUDA else "cpu")

class LinearRegression(nn.Module):
    def __init__(self):
        super(LinearRegression,self).__init__()
        self.linear=nn.Linear(1,1)
    def forward(self, x):
        out=self.linear(x)
        return out

model=LinearRegression()
if torch.cuda.device_count() > 1:#判断是不是有多个GPU
    print("Let's use", torch.cuda.device_count(), "GPUs!")
    # 就这一行
    model = nn.DataParallel(model, device_ids=range(torch.cuda.device_count()))
model.to(device)#将设备先复制到主设备上

criterion = nn.MSELoss()
optimizer = optim.SGD(model.parameters(),lr=1e-4)

num_epochs=1000
for epoch in range(num_epochs):
    inputs = Variable(x_train.cuda())
    target = Variable(y_train.cuda())
    out = model(inputs)
    loss=criterion(out,target)
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
    if (epoch+1) % 20 == 0:
        print('Epoch[{}/{}], loss: {:.6f}'
              .format(epoch+1, num_epochs, loss.item()))
model.eval()
predict = model(Variable(x_train.cuda()))
predict = predict.cpu().data.numpy()
plt.plot(x_train.numpy(), y_train.numpy(), 'ro', label='Original data')
plt.plot(x_train.numpy(), predict, label='Fitting Line')
# 显示图例
plt.legend()
plt.show()
# 保存模型
torch.save(model.state_dict(), './linear.pth')
```