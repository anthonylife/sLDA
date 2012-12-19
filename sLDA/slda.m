% sLDA achieves the version of supervised topic model introduced in paper
% (Supervised Topic Model, NIPS, 2007) using variational EM method to 
% learn the model parameters.
%
% Procedures:
%   (1).Initialization, including:
%       (1.1)global variables and model parameters setting;
%       (1.2)review text loading;
%   (2).For each document, do variational inference;
%   (3).Evaluation, mainly including prediction.
%
% Date: 12/11/2012


% (1)----------------------------------------------
% Global variable and model hyperparameters setting
% =================================================
% debug variable
%if 0,
global doc_llhood;

rand('state', sum(100*clock));

trainfile = '../datasets/train_review.dat';
testfile = '../datasets/test_review.dat';
resultfile = '../results/result.slda.txt';

maxIter = 200;   % maximal number of iterations for VBEM
vbe_maxIter = 80;   % maximal number of iteration for VBE-step
wordNum = 12000;    % just based on dictionary statistic information
traindata = loadreview(trainfile, wordNum);  % load review text data

% model parameters
global model;
model.K = 20;   % topic dimension
model.alpha = repmat(1/model.K, 1, model.K);
%model.beta = repmat(1/wordNum, model.K, wordNum);   % model word-topic paras
model.beta = normalize(rand(model.K, wordNum),2);
model.eta = repmat(0.0, model.K+1, 1);  % new parameter relative to LDA
model.sigma = var(traindata.rate);  % use real ratings' variance  
model.gammas = repmat(0.0, traindata.docnum, model.K);


% (2)-------------------------------------------
% For each document, do variational EM inference
tic;
fprintf(1, 'Number of documents      = %d\n', traindata.docnum);
fprintf(1, 'Number of words          = %d\n', wordNum);
fprintf(1, 'Number of latent classes = %d\n', model.K);
    
% block coordinate-ascent variational inference
% variational bayesian E-step
% ===========================
model.betas = repmat(0, wordNum, model.K);  % variational parameters
% notes it needs to be accumulated for each document

global betas;
betas = repmat(1/model.K, wordNum, model.K);

% additional two expectation values used for updating 'eta' and 'sigma'
E_A = repmat(0.0, traindata.docnum, model.K+1);
E_AA = repmat(0.0, model.K+1, model.K+1);

wfd = fopen(resultfile, 'w');
% training iteration starts
for iter=1:maxIter,
    corp_llhood = 0;
    fprintf(1,'iteration %d/%d...\t',iter,maxIter);
    fprintf(wfd,'iteration %d/%d...\t',iter,maxIter);
    
    for i=1:traindata.docnum,
        [E_A(i,:), E_AA] = vbe_step(traindata.doc(i)...
            , wordNum, E_AA, vbe_maxIter);
        accum_para(traindata.doc(i), wordNum);
    end
    
    % variational bayesian M-step
    % ===========================
    vbm_step(traindata, E_A, E_AA);
    
    % compute train data log-likelihood
    % =================================
    %[corp_llhood, perword_llhood]= getcorpllhood(traindata, 'eval');
    [corp_llhood, perword_llhood]= slda_lik(traindata);
    fprintf('Corpus log-likelihood = %f, ', corp_llhood);
    fprintf('per-word log-likelihood = %f...\t',perword_llhood);
    elapsed = toc;
    fprintf(1,'RTS:%s (%d sec/step)\n', ...
	    rtime(elapsed * ( maxIter / iter  - 1)), round(elapsed / iter));
    
    % clear
    E_A(:,:) = 0.0;
    E_AA(:,:) = 0.0;
    model.betas(:,:) = 0;
end
fclose(wfd);
elapsed = toc;
fprintf('\nTotal time cost = %s\n', rtime(elapsed));
%end
model.betas(:,:) = 0;

% (3)------------------------------
% Rating Prediction on the test set
% =================================
fprintf(1, 'Evaluation the prediction results on test data\n');

testdata = loadreview(testfile, wordNum);
pre_rate = repmat(0.0, 1, testdata.docnum);

% words occured in trian data
dict = find(sum(model.beta, 1)~=0);
vbe_maxIter = 40;   % maximal number of iteration for VBE-step

% Strategy 1:
% inference and predict
for i=1:testdata.docnum,
    % Remove words not occur train data.
    [comid, idx_src, idx_tar] = intersect(testdata.doc(i).word_id, dict);
    testdata.doc(i).word_id = testdata.doc(i).word_id(idx_src);
    testdata.doc(i).word = testdata.doc(i).word(idx_src);
    
    [temp0, temp1] = vbe_step(testdata.doc(i), wordNum, -1, vbe_maxIter);
    aver_beta = sum(diag(testdata.doc(i).word)...
        *betas(testdata.doc(i).word_id, :), 1)...
        ./testdata.doc(i).docwordnum;
    pre_rate(i) = [aver_beta, 1] * model.eta;
end
eval_result = predictiveR2(testdata.rate, pre_rate);
fprintf('================================================\n');
fprintf(1, 'The result of predictive R2 for sLDA method 1 is %f\n', eval_result);

% Strategy 2:
% inference
%{
for i=1:testdata.docnum,
    % Remove words not occur train data.
    [comid, idx_src, idx_tar] = intersect(testdata.doc(i).word_id, dict);
    testdata.doc(i).word_id = testdata.doc(i).word_id(idx_src);
    testdata.doc(i).word = testdata.doc(i).word(idx_src);
    
    [temp0, temp1] = vbe_step(testdata.doc(i), wordNum, -1, vbe_maxIter);
    accum_para(testdata.doc(i), wordNum);
end

model.betas = normalize(model.betas, 2);

% predict
for i=1:testdata.docnum,
    aver_beta = sum(diag(testdata.doc(i).word)...
        *model.betas(testdata.doc(i).word_id, :), 1)...
        ./testdata.doc(i).docwordnum;
    pre_rate(i) = [aver_beta, 1] * model.eta;
end

eval_result = predictiveR2(testdata.rate, pre_rate);
fprintf('================================================\n');
fprintf(1, 'The result of predictive R2 for sLDA method 2 is %f\n', eval_result);
%}
