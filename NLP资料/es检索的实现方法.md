

[看教程啊](http://www.data-master.net/83411704)


```

from elasticsearch import Elasticsearch
import jieba

# 默认host为localhost,port为9200.但也可以指定host与port
es = Elasticsearch(hosts="http://172.18.8.35:9200", doc_type="faq", index="faq")

question = "公司的婚假规定是什么"
word_conds = " ".join(jieba.cut_for_search(question))
query = {
    "query":
        {
            "bool":
                {
                    "must":
                        [

                            {"terms": {"questionGroupId": [1350152425730048]}},
                            {"query_string": {"default_field": "wordList", "query": word_conds}},

                        ],
                    "should":
                        [
                            {"match": {"question": question}}
                        ]

                },
        },
}
# query={
#     "query":{
#         "term":{
#             "faqLibId":1342996471214336
#         }
#     }
# }
# query = {
#     "query": {
#         "constant_score": {
#             "filter": {
#                 "term": {
#                     "faqLibId": 1342996471214336
#                 }}
#         }
#     }
# }
result = es.search(index="faq", body=query, size=5, from_=0)
for item in result["hits"]["hits"]:
    print(item)
```