####json越来越流行，通过python获取到json格式的字符串后，可以通过eval函数转换成dict格式：

```
a='{"name":"yct","age":10}'
eval(a)
{'age': 10, 'name': 'yct'}
```