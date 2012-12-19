function ldaVariation(feature_file, k, emmax, demmax)
% Latent Dirichlet Allocation, standard model.
% Copyright (c) 2004 Daichi Mochihashi, all rights reserved.
% $Id: lda.m,v 1.7 2004/11/08 12:31:46 dmochiha Exp $
%
% Small modifications made by Anthonylife in 12/16/2012   
%
% lda(feature_file, k,[emmax,demmax])
% d      : data of documents
% k      : # of classes to assume
% emmax  : # of maximum VB-EM iteration (default 100)
% demmax : # of maximum VB-EM iteration for a document (default 20)


if nargin < 4
  demmax = 20;
  if nargin < 3
    emmax = 100;
  end
end

% setting of the path of data files
train_data_file = '../datasets/train_review.dat';
test_data_file = '../datasets/test_review.dat';

% debug
% -----
%k = 20;
%emmax = 1;
%demmax = 20;
% ----------

[d, totalwords] = fmatrix(train_data_file);
n = length(d);
l = 12000;    % l is the maximal id of features
%beta = ones(l,k) / l;
beta = mnormalize(rand(l, k), 1);
alpha = repmat(1/k, 1, k);
gammas = zeros(n,k);    % the corresponding variational parameter of alpha
lik = 0;
plik = lik;
tic;

fprintf(1,'number of documents      = %d\n', n);
fprintf(1,'number of words          = %d\n', l);
fprintf(1,'number of latent classes = %d\n', k);
for j = 1:emmax
  fprintf(1,'iteration %d/%d...\t',j,emmax);
  % vb-estep
  betas = zeros(l,k);   % variational paramter for beta.
  for i = 1:n
    [gamma,q] = vbem(d{i},beta,alpha,demmax);
    % Here, q is equal to the standard representation of phi
    gammas(i,:) = gamma;
    betas = accum_beta(betas,q,d{i});   % collection.
  end
  % vb-mstep
  alpha = newton_alpha(gammas);
  %betas = smooth_para(betas);
  beta = mnormalize(betas,1);
  % converge?
  [loglik, perwd_loglik]= lda_lik(d,beta,gammas,totalwords);
  fprintf('Corpus log-likelihood = %f, per-word log-likelihood = %f...\t', loglik, perwd_loglik);
  elapsed = toc;
  fprintf(1,'ETA:%s (%d sec/step)\n', ...
	  rtime(elapsed * (emmax / j  - 1)),round(elapsed / j));
  if (j > 1) && converged(lik, plik, 1.0e-4)
    if (j < 5)
      fprintf(1,'\n');
      ldaVariation(feature_file, k, emmax, demmax); % try again!
      return;
    end
    fprintf(1,'\nconverged.\n');
    return;
  end
  plik = lik;
  % ETA
end
elapsed = toc;
fprintf(1, 'Total time cost:%s', rtime(elapsed));
fprintf(1,'\n');

% Extract topic features
fprintf(1, 'Extract topic features from training data.\n');
tr_fea = repmat(0.0, n, k);
for i = 1:n,
    [gamma, q] = vbem(d{i}, beta, alpha, demmax);   
    doc_topic = sum(diag(d{i}.cnt)*q, 1);
    tr_fea(i,:) = doc_topic ./ sum(doc_topic);
end

fprintf(1, 'Extract topic features from test data.\n');
d = fmatrix(test_data_file);
n = length(d);
te_fea = repmat(0.0, n, k);

% words occured in trian data
dict = find(sum(beta, 2)~=0);

for i = 1:n,
    % Remove words not occur train data.
    [comid, idx_src, idx_tar] = intersect(d{i}.id, dict);
    d{i}.id = d{i}.id(idx_src);
    d{i}.cnt = d{i}.cnt(idx_src);
    
    [gamma, q] = vbem(d{i}, beta, alpha, demmax);   
    doc_topic = sum(diag(d{i}.cnt)*q, 1);
    te_fea(i,:) = doc_topic ./ sum(doc_topic);
end

% save features
save(feature_file, 'tr_fea', 'te_fea');
fprintf('Finish.\n');
