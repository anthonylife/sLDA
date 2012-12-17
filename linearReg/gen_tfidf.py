#!/usr/bin/env python
#encoding=utf8
#
# GEN_TFIDF generate TF-IDF features for each document.
#
# Date: 12/16/2012

import math

data_file = ['../datasets/train_review.dat', '../datasets/test_review.dat']
feature_file = '../features/review_features.tf-idf.txt'

skip_header = 2
total_wordnum = 12000
total_docnum = 5000
wd_doc = {}             # word belongs how many documents
docs = []               # tf-idf value in each document

for docname in data_file:
    for line in open(docname):
        maxwordcnt = 0
        doc = [0.0 for i in range(total_wordnum)]
        res = line.strip('\n').split(' ')
        for item in res[skip_header:]:
            bi_item = item.split(':')
            temp_cnt = int(bi_item[1])
            temp_id = int(bi_item[0]) - 1
            doc[temp_id] = temp_cnt
            if maxwordcnt < temp_cnt:
                maxwordcnt = temp_cnt
            if temp_id in wd_doc:
                wd_doc[temp_id] += 1
            else:
                wd_doc[temp_id] = 1
        doc = map(lambda x: float(x)/maxwordcnt, doc)
        docs.append(doc)

wfd = open(feature_file, 'w')
for doc in docs:
    for i, word_cnt in enumerate(doc):
        if word_cnt > 0:
            wfd.write('%f ' % (word_cnt * math.log(float(total_docnum) / wd_doc[i])))
        else:
            wfd.write('0 ')
    wfd.write('\n')
wfd.close()
