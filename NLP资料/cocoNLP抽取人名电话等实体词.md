

##安装cocoNLP

* 安装

在unix系统下首先，pip install coconlp 然后下载funnlp的data集复制到coconlp的static的文件夹下即可。

* 使用

```python

from cocoNLP.extractor import extractor

ex = extractor()

text = '急寻特朗普，男孩，于2018年11月27号11时在陕西省安康市汉滨区走失。身份证号码410105196904010537丢失发型短发，...' \
       '如有线索，请迅速与警方联系：18100065143，132-6156-2938，baizhantang@sina.com.cn 和yangyangfuture at gmail dot com13673630861'
text = '急寻特朗普，男孩，于2018年11月27号11时在鼓楼区走失。身份证号码410105196904010537丢失发型短发，...' \
       '如有线索，请迅速与警方联系：18100065143，132-6156-2938，baizhantang@sina.com.cn 和yangyangfuture at gmail dot com13673630861'
text = '4点15分钟后的番茄炒蛋'
text = '我下午2点15分30秒的番茄炒蛋'
text = '晚上8点15的番茄炒蛋'


# 抽取邮箱
emails = ex.extract_email(text)
print(emails)
#
# # 抽取手机号
cellphones = ex.extract_cellphone(text,nation='CHN')
print(cellphones)
#
# # 抽取身份证号
ids = ex.extract_ids(text)
print(ids)
#
# # 抽取手机归属地、运营商
cell_locs = [ex.extract_cellphone_location(cell,'CHN') for cell in cellphones]
print(cell_locs)
#
# # 抽取地址信息
locations = ex.extract_locations(text)
print(locations)
#
# # 抽取时间点
times = ex.extract_time(text)
print(times)

# 抽取人名
name = ex.extract_name("打电话给辛洪生告诉他参加会议")
print(name)
```