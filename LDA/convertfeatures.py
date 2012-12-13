#!user/bin/env python
#encoding=utf8

# CONVERTFEATURES convert the origin format of review text data
# to the format we previouly specified for basic LDA for consistence.

# Date: 12/12/2012

srcfiles = ['../datasets/train_review.dat', '../datasets/test_review.dat'];
featurefiles = ['../datasets/train_review.lda', '../datasets/test_review.lda'];
ratefiles = ['../datasets/train_review.rate', '../datasets/test_review.rate'];

docIdx = 1
for i, srcfile in enumerate(srcfiles):
    wfd_f = open(featurefiles[i], 'w')
    wfd_r = open(ratefiles[i], 'w')
    for line in open(srcfile):
        res = line.strip('\n').split(' ')
        wfd_r.write('%d %f\n' % (docIdx, float(res[1])))
        for item in res[2:]:
            [wdIdx, wdCnt] = item.split(':')
            wfd_f.write('%d %d %d\n' % (docIdx, int(wdIdx), int(wdCnt)))
        docIdx += 1
    wfd_f.close()
    wfd_r.close()
