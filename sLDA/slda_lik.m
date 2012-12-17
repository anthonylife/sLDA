function [loglik, perwd_loglik] = slda_lik(traindata)
%
% SLDA_LIK computes the log-likelihood of the whole corpus 
%


global model;

Pz_d = diag(1./sum(model.gammas, 2)) * model.gammas;
Pw_z = diag(1./sum(model.betas', 2)) * model.betas';

loglik = 0.0;
for i=1:length(traindata.doc),
    doc = traindata.doc(i);
    loglik = loglik + log(1/length(traindata.doc)) ...
        + sum(doc.word.*log(Pz_d(i,:)*Pw_z(:, doc.word_id)));
end
perwd_loglik = loglik / traindata.totalwords;
