src/lda -est -alpha 1 -beta 0.1 -ntopics 20 -niters 30 -dfile ../datasets/train_review.dat
src/lda -inf -dir ../features/ -model review.lda.gibbs++.tr -niters 20 -dfile ../datasets/test_review.dat
