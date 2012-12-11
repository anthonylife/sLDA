The Hotel Review dataset consists of both training and testing sets, 
with the file names being rev2500_6000_nlp_lda_voc12000_5000_train.dat 
and rev2500_6000_nlp_lda_voc12000_5000_test.dat, respectively.

The training set consists of 2,500 hotel review documents, represented 
in the format of bag-of-words. Each line in the file corresponds to one 
review document and it has the following information:

[number of terms] [review score] [term-id:number-of-appearances] [term-id:number-of-appearances] [term-id:number-of-appearances] ...

The testing set has the same size and the same format as the training set.

In total, we have five types of review scores, which was originally 1, 2, 3, 4 and 5. 
For doing regression, we have normalized them to get the current scores, which
are -0.9575, -0.2644, 0.1411, 0.4288, and 0.6519.

Finally, the file "rev2500_6000_voc12000_alpha.dat" consists of the 
unique terms (words) in the dictionary. In total, we have 12,000 words.
The dictionary can be used to interpret the semantic meanings of the
learned topics.