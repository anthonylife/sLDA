function lr(feature_file, topics)
% LR is an implementation of linear regression model with L2
% regularization. As the total number of the train features 
% is small, I just solve the parameters by setting their 
% gradients to 0 and get the closed form solution. 
% An alternative strategy is to use stochastic gradient
% descent (SGD) algorithm to train the model parameters,
% when the train data set is large.
% 
% Procedures:
%   1.Initialization:
%       1.1 Global variables and model hyper-parameters setting.
%       1.2 Loading train data and rating information.
%   2.Setting the gradients and get the closed form result.
%   3.Evaluation.   
%
% Date: 12/13/2012


% (1)-----------
% Initialization
% ==============
fea_dim = topics;
tr_rate_file = '../datasets/train_review.rate';
te_rate_file = '../datasets/test_review.rate';

model.reg_para = 0.1;
model.W = repmat(0.0, fea_dim+1, 1);

if nargin < 3,
    load(feature_file);    % get 'tr_fea' and 'te_fea' 
else,
    fea = load(feature_file);
    docnum = size(fea, 1);
    tr_fea = fea(1:docnum/2, :);
    te_fea = fea(docnum/2+1:end, :);
end

% read real ratings
tr_rate = load(tr_rate_file);
te_rate = load(te_rate_file);

% (2)---------------------------------------------------
% Setting the gradients and get the closed form solution
% ======================================================
tr_fea(:,fea_dim+1) = 1;    % bias item
te_fea(:,fea_dim+1) = 1;

% closed form solution
model.W = inv(model.reg_para*eye(fea_dim+1)+tr_fea'*tr_fea)...
    *tr_fea'*tr_rate(:, 2);

% (3)-------
% Evaluation
% ==========
%model.W
pre_rate = model.W' * te_fea';
%pre_rate(1:100)
eval_result = predictiveR2(te_rate(:,2)', pre_rate);
fprintf(1,'==================================================\n');
fprintf(1, 'The result of predictive R2 for linear regression');
fprintf(1, 'with LDA topic features is %f\n', eval_result);
