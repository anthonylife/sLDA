% MAIN is the start function to call all the methods in the
% experiments.
% 
% Settings:
%   choice : 'tr_tst' stands for doing both training and test; while
%            'tst' only does test based on optimized parameters.
%            Default is 'tst'.
%   method : including topic features using 'gibbs' or 'variational
%            method' or word features 'tf-idf'.
%
% Author: anthonylife
% Date: 12/15/2012

% Only learning or learning and prediction
choice = 'tr_tst';
%choice = 'tst';

% Learning methods
%method = 'tfidfLr';     % tf-idf of all words as features for linear regression
%method = 'lassoLr';      % feature leanring + 'tf-idf'
%method = 'gibbsLda';      % topic as features with matlab gibbs implementation 
%method = 'gibbs++Lda';     % topic as features with C++ gibbs implementation
%method = 'variationLda';  % topic as features with matlab variational method implementation
method = 'discLda';    % adopt discriminative learning in supervised LDA:
                        %   1.Gibbs sampling in E-step; 2.MLE-in M-step
%method = 'sLda';       % supervised LDA with block coordinate descent method (variational)

if choice == 'tr_tst',
    switch method,
    case 'gibbsLda',
        topics = 20;
        gibbs_maxiter = 500;
        feature_file = './features/review_features.lda.gibbs.mat';
        ldaGibbs(feature_file, topics, gibbs_maxiter);
        % Linear regression using least squre method
        lr(feature_file, topics);
    
    case 'gibbs++Lda',
        topics = 40;
        gibbs_maxiter = 2000;     % for training
        train_data_file = './datasets/train_review.dat';
        test_data_file = './datasets/test_review.dat';
        train_feature = './features/review_features.lda.gibbs++.tr.txt';
        test_feature = './features/review_features.lda.gibbs++.tst.txt';

        % splice string to form commander of training
        cmd = './ldaGibbs++/src/lda -est -alpha 1.25 -beta 0.1 -ntopics ';
        cmd = [cmd, num2str(topics), ' -niters ', num2str(gibbs_maxiter),...
            ' -dfile ', train_data_file];
        system(cmd);

        % splice string to form commander of testing
        gibbs_maxiter = 400;     % for inference on new data
        model_prefix = 'review.lda.gibbs++.tr';
        cmd = './ldaGibbs++/src/lda -inf -dir ./features/ -model ';
        cmd = [cmd, model_prefix, ' -niters ', num2str(gibbs_maxiter),...
            ' -dfile ', test_data_file];
        system(cmd);

        % call linear regression
        lr(train_feature, topics, test_feature);

    case 'variationLda',
        topics = 25;
        em_maxiter = 200;
        dem_maxiter = 80;
        feature_file = './features/review_features.lda.vari.mat';
        ldaVariation(feature_file, topics, em_maxiter, dem_maxiter);
        % Linear regression using least squre method
        lr(feature_file, topics);
    
    case 'tfidfLr',
        topics = 12000; % count of total unique words
        feature_file = './features/review_features.tf-idf.txt';
        % Linear regression using stochastic gradient descent
        lrsgd(topics, feature_file);

    case 'lassoLr',
        topics = 12000; % count of total unique words
        feature_file = './features/review_features.tf-idf.txt';
        % sparse linear regression with coordinate descent algorithm
        lrlasso(topics, feature_file);

    case 'discLda',
        topics = 20;
        out_disc_iter = 100;
        train_data_file = './datasets/train_review.dat';
        test_data_file = './datasets/test_review.dat';
        
        % splice string to form commander of training
        cmd = './discLDA/src/lda -est -alpha 2.5 -beta 0.1 -ntopics ';
        cmd = [cmd, num2str(topics), ' -niters ', num2str(out_disc_iter),...
            ' -dfile ', train_data_file];
        system(cmd);
    
        % splice string to form commander of testing
        test_maxiter = 400;     % for inference on new data
        model_prefix = 'review.lda.gibbs++.tr';
        cmd = './discLDA/src/lda -inf -dir ./features/ -model ';
        cmd = [cmd, model_prefix, ' -niters ', num2str(test_maxiter),...
            ' -dfile ', test_data_file];
        system(cmd);
        
        % prediction with disc LDA
        discLr();
    
    case 'sLda',
        topics = 20;
        em_max_iter = 200;
        vbe_max_iter = 80;
        slda(topics, em_max_iter, vbe_max_iter);

    otherwise,
        error('Invalid method choice.');
    end

elseif choice == 'tst',
    break;
end

