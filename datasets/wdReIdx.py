#!/usr/bin/env python
#encoding=utf8

# As the NO. of words in training and test files is 1
# smaller than the No. of words in vocabulary file.
# Thus, we need to re-index them.

inputfile = ['train_review.dat', 'test_review.dat']
outputfile = ['train_review.1.dat', 'test_review.1.dat']

for i, doc in enumerate(inputfile):
    wfd = open(outputfile[i], 'w')
    for line in open(doc):
        res = line.strip('\n').split(' ')
        wfd.write('%s %s' % (res[0], res[1]))
        for item in res[2:]:
            biparts = item.split(':')
            biparts[0] = str(int(biparts[0])+1)
            wfd.write(' %s:%s' % (biparts[0], biparts[1]))
        wfd.write('\n')
    wfd.close()
