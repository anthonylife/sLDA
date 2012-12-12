% sLDA achieves the version of supervised topic model introduced in paper
% (Supervised Topic Model, NIPS, 2007) using variational EM method to 
% learn the model parameters.
%
% Procedures:
%   (1).Initialization, including:
%       (1.1)global variables and model parameters setting;
%       (1.2)review text loading;
%   (2).For each document, do variational inference;
%   (3).Evaluation, mainly prediction.
%
% Date: 12/11/2012
%


% (1)----------------------------------------------
% Global variable and model hyperparameters setting
% =================================================
trainfile = '../datasets/train.dat';
testfile = '../datasets/test.dat';

maxIter = 50;   % maximal number of iterations for VBEM
vbe_maxIter = 20;   % maximal number of iteration for VBE-step
wordNum = 12000;
traindata = loadreview(trainfile, wordNum);  % load review text data

global model;
model.K = 20;   % topic dimension
model.alpha = repmat(1/model.K, 1, model.K);
model.beta = repmat(1/wordNum, model.K, wordNum);
model.eta = repmat(1/model.K, model.K, 1);  % new parameter relative to LDA
model.sigma = 1;    
model.gammas = repmat(model.alpha+repmat(traindata.doc(i).docwordnum/...
    model.K, 1, model.K), traindata.docnum, 1);   % variational parameter


% (2)-------------------------------------------
% For each document, do variational EM inference
tic;
fprintf(1, 'Number of documents = %d\n', traindata.docnum);
fprintf(1, 'Number of words     = %d\n', wordNum);
fprintf(1, 'Number of topics    = %d\n', model.K);

for iter=1:maxIter,
    fprintf(1, 'Current number of iterations: %d\n', iter);
    
    % block coordinate-ascent variational inference
    % variational bayesian E-step
    % ===========================
    model.betas = repmat(0, wordNum, model.K);  % variational parameters
    % notes it needs to be accumulated for each document
    
    for i=1:traindata.docnum,
        betas = vbe_step(traindata.doc(i), wordNum, vbe_maxIter);    
        model.betas = accum_para(model.betas, betas, traindata.doc(i));
    end

    % variational bayesian M-step
    % ===========================
    vbm_step(traindata.doc(i));

    % compute train data log-likelihood
    % =================================
end