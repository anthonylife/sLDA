Author: Anthonylife
Date: 12/15/2012
-------------------

Note: On the one hand, I implement Gibbs sampling version of lda and 
variational bayesian version of Supervised LDA.

Result Cache:
=============
result format: topic num, predictive R2, time.

Basic LR:
0.544

sLDA:
5, 0.504, 8812
10, 0.507, 11338
15, 0.524, 13261
20, 0.545, 14953,   
25, 0.516, 15696,   -7.27

20, 0.509,  -7.30

LDA:
5,  0.412,  24min37s,   -7.50
10, 0.473,  32min15s,   -7.40 
15, 0.489,  40min38s,   -7.34
20, 0.489,  50min16s,   -7.28
25, 0.474,  20min35s,   -7.25
30, 0.477,  22min6s,    -7.22
35, 0.470,  23min32s,   -7.20
40, 0.481,  53min10s,   -7.16
45, 0.477,  1h21min44s, -7.14
