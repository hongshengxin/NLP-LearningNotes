

[看教程啊](http://www.data-master.net/83411704)


###  ES方法的创建

```
class ESUtility():
    @staticmethod
    def create_index(hosts, index, body=None):
        from elasticsearch import Elasticsearch
        es = Elasticsearch(hosts=hosts)
        return es.indices.create(index=index, body=body)

    @staticmethod
    def delete_index(hosts, index):
        from elasticsearch import Elasticsearch
        es = Elasticsearch(hosts=hosts)
        return es.indices.delete(index)

    @staticmethod
    def getInstance():
        from nlpservice.config import ES_CONFIG
        return ESUtility(hosts=ES_CONFIG["host"], index=ES_CONFIG["index"], doc_type=ES_CONFIG["doc_type"])

    def __init__(self, hosts=None, **kwargs):
        from elasticsearch import Elasticsearch

        self.es = Elasticsearch(hosts=hosts, **kwargs)
        self.index = kwargs.get('index')
        self.doc_type = kwargs.get('doc_type')

    def create_doc(self, body):
        return self.es.index(index=self.index, doc_type=self.doc_type, body=body)

    def delete_doc(self, _id):
        return self.es.delete(index=self.index, doc_type=sel
       return self.es.delete(index=self.index, doc_type=sel
    def get_faq(self, id):
        return self.es.get(self.index, self.doc_type, id)

    def search_faqbyworlist(self, faq_questionIds, word_list, question, from_=0, size=10):
        es_result = self.search_faq(faq_questionIds, word_list, question, from_, size)
        return es_result['hits']['hits']

    def search_faq(self, faq_questionIds, word_list, question, from_=0, size=10):
        question = question.replace('"', '')
        word_list = [w.replace('"', '').lower() for w in word_list]
        word_conds = " ".join(word_list)
        query = {
            "query":  # 关键字，把查询语句给 query
                {
                    "bool":
                        {  # 关键字，表示使用 filter 查询，没有匹配度
                            "must":  # 表示里面的条件必须匹配，多个匹配元素可以放在列表里
                                [
                                    {"terms": {"questionId": faq_questionIds}},
                                    # 字符串检索query_string 全局搜索
                                    {"query_string": {"default_field": "wordList", "query": word_conds}},
                                ],
                            "should":  # must(都满足),should(其中一个满足),must_not(都不满足)
                                [
                                    {"match": {"question": question}}
                                ]
                        },
                },
        }
        return self.es.search(index=self.index, doc_type=self.doc_type, body=query, from_=from_, size=size)

    def search_faq_byquestionId(self, faq_questionIds, from_=0, size=10):
        query = {
            "query": {
                "terms": {
                    "questionId":
                        faq_questionIds
                }
            }
        }
        es_result = self.es.search(index=self.index, doc_type=self.doc_type, body=query, from_=from_, size=size)
        return es_result['hits']['hits']



```

### ES 查询的使用


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