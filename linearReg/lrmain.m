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
method = 'variation';
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
    
    case 'variation',
        topics = 20;
        em_maxiter = 100;
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

