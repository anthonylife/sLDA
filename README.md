****************************************************************************

                        Review Rating Prediction
       A variety of mplementations of models used for predicting review 
       ratings. They are linear regression, sparse linear regression,
       basic topic model, supervised topic model.

                            Author: Anthonylife
                            Date: 12/27/2012

****************************************************************************

1. Introduction
===============
This project concentrates on review rating prediction. The data set
is consisted of 5000 documents. The first 2500 documents are used as
traning data while the second used as test data. Each document owns
a rating value which is an iterger from 1-5.

Many models or methods can be used to solve this problem. In this
programme, we focus on using regression model to predict the rating
values. What matters most for us are the features how they are generated
and used. Note multi-class classification is also OK here.

A variety of mplementations of models used for predicting review 
ratings. They are linear regression, sparse linear regression,
basic topic model, supervised topic model.

2. How to Run all Related Models
Two steps are OK. After launching the MATLAB software in the commander,
    1. excute "initpath.m" to add temporal path to the current workspace;
    2. excute "main.m" to run the code.
        "main.m" is a function contains all the start codes to run all the
        models. Users should modify the code to set the model selection
        option. More detailes can be seen in the file.
 
3. Additional library source files
    1.IT++: C++ library of mathmatical computation, with similar coding
      style like MATLAB.
      URL: http://itpp.sourceforge.net/stable/

4. Code files layout
dataset/
    :: Raw data files
    train_review.dat --> train data file
    test_review.dat  --> test data file
    ...

evaluation/
    :: evaluation scripts
    predictiveR2.m  --> implementation of evaluation metric 

linearReg/
    :: multiple linear regression codes
    gen_tfidf.py    --> generates TF-IDF value as features
    lr.m            --> linear regression with closed-form solution when 
                        the number of features is samll, e.g., topic model
    lrsgd.m         --> linear regression with all words as features
    lrlasso.m       --> linear regreesion with L1-norm regularization

ldaGibbs/
    :: standard topic model with Gibbs Sampling, Matlab.
    ldaGibbs.m      --> main code file
    all other files are packed in "private" directory...

ldaVariation/
    :: standard topic model with Variational Bayesian, Matlab.
    ldaVariation.m  --> main code file
    all other files are packed in "private" directory...

ldaGibbs++/
    :: modification of an existed C++ implemention of Gibbs Sampling

sLDA/
    :: supervised topic model with Variational Bayesian Learning
    slda.m          --> main code file
    vbe_step.m      --> variational bayesian E-step
    vbm_step.m      --> variational bayesian M-step
    ...
discLDA/
    :: supervised topic model with Gibbs Sampling EM algorithm
    src/lda.cpp     --> start code
    src/model.cpp   --> main code

5.Predictive results
see file "Result.txt" for more information.

****************************************************************************

Note, currently, I implemente Supervised topic model by matlab, basic LDA with
Gibbs sampling by matlab. I also give a little modification for  basic LDA
with variational inference written by other users. Moreover, in order to
speed up the procedure of Gibbs sampling, I also modified LDAGIBBS++, the C++
version written by Xuan-Hieu Phan. More details can be seen in the sub-directory
in each method.
