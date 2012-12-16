%function lrsgd(feature_file, topics)
%
% LRSGD is an implementation of linear regression using
% stochastic gradient descent (SGD) algorithm to train
% model parameters. This is particularlly useful when
%
%
% Date: 12/16/2012


%----Debug------
topics = 12000; % count of total unique words
feature_file = '../features/review_features.tf-idf.txt';
%---------------

% (1)-----------
% Initialization
% ==============
fea_dim = topics;
tr_rate_file = '../datasets/train_review.rate';
te_rate_file = '../datasets/test_review.rate';

% read features
fea = load(feature_file);
docnum = size(fea, 1);
tr_fea = fea(1:docnum/2, :);
te_fea = fea(docnum/2+1:end, :);
clear fea;

% read real ratings
tr_rate = load(tr_rate_file);
te_rate = load(te_rate_file);
tr_fea(:,fea_dim+1) = 1;    % bias item
te_fea(:,fea_dim+1) = 1;

% settings
max_iter = 300;
lrate = 1e-4;
threshold = 1e-1;
model.reg_para = 0.1;
model.W = repmat(0.0, fea_dim+1, 1);

% Start sgd
err_old = 0;
err_new = 0;
for i=1:max_iter,
    seq = randperm(docnum/2);
    for j=seq,
        model.W = model.W - lrate*(2*(tr_fea(j,:)*model.W...
            -tr_rate(j, 2))*tr_fea(j,:)'+model.reg_para*model.W);
    end
    err_new = (tr_fea*model.W - tr_rate(:,2))'*(tr_fea*model.W - tr_rate(:,2));
    fprintf(1,'Current error: %f...\n', err_new);
    if abs(err_new-err_old) < threshold
        break;
    end
    err_old = err_new;
end

% (3)-------
% Evaluation
% ==========
pre_rate = model.W' * te_fea';
eval_result = predictiveR2(te_rate(:,2)', pre_rate);
fprintf(1, 'The result of predictive R2 for linear regression');
fprintf(1, 'with LDA topic features is %f\n', eval_result);
