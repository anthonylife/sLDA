% LRMAIN is the start function to call lda with gibbs sampling and
% linear regression model to predict the rating of reviews.
% 
% Settings:
%   choice : 'tr_tst' stands for doing both training and test; while
%            'tst' only does test based on optimized parameters.
%            Default is 'tst'.
%   topics : setting the number of topics, default is 5.
%   method : including topic features using 'gibbs' or 'variational
%            method' or word features 'tf-idf'.
%
% Author: anthonylife
% Date: 12/15/2012

choice = 'tr_tst';
%method = 'gibbs';
method = 'gibbs++';
%method = 'variation';
%method = 'tf-idf';

if choice == 'tr_tst',
    switch method,
    case 'gibbs',
        topics = 20;
        gibbs_maxiter = 500;
        feature_file = '../features/review_features.lda.gibbs.mat';
        ldaGibbs(feature_file, topics, gibbs_maxiter);
        % Linear regression using least squre method
        lr(feature_file, topics);
    
    case 'gibbs++',
        topics = 20;
        gibbs_maxiter = 1000;     % for training
        train_data_file = '../datasets/train_review.dat';
        test_data_file = '../datasets/test_review.dat';
        train_feature = '../features/review_features.lda.gibbs++.theta.tr.txt';
        test_feature = '../features/review_features.lda.gibbs++.theta.tst.txt';

        % splice string to form commander of training
        cmd = '../discLDA/src/lda -est -alpha 0.5 -beta 0.1 -ntopics ';
        cmd = [cmd, num2str(topics), ' -niters ', num2str(gibbs_maxiter),...
            ' -dfile ', train_data_file];
        system(cmd);

        % splice string to form commander of testing
        gibbs_maxiter = 100;     % for inference on new data
        model_prefix = 'review.lda.gibbs++.tr';
        cmd = '../discLDA/src/lda -inf -dir ../features/ -model ';
        cmd = [cmd, model_prefix, ' -niters ', num2str(gibbs_maxiter),...
            ' -dfile ', test_data_file];
        system(cmd);

        % call linear regression
        lr(train_feature, topics, test_feature);

    case 'variation',
        topics = 25;
        em_maxiter = 200;
        dem_maxiter = 20;
        feature_file = '../features/review_features.lda.vari.mat';
        ldaVariation(feature_file, topics, em_maxiter, dem_maxiter);
        % Linear regression using least squre method
        lr(feature_file, topics);
    
    case 'tf-idf',
        topics = 12000; % count of total unique words
        feature_file = '../features/review_features.tf-idf.txt';
        % Linear regression using stochastic gradient descent
        lrsgd(topics, feature_file);
    
    otherwise,
        error('Invalid method choice.');
    end
end

