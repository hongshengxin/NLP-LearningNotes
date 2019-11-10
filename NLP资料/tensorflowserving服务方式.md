

# Tensorflow serving使用教程


## 一. tensorflow代码实现serving方法

### 将模型保存为pb文件，tensorflow serving支持pb模型的文件

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



## 2. 使用docker 部署环境
