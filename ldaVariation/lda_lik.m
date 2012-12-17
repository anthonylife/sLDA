function [loglik, perwd_loglik] = slda_lik(d, beta, gammas, totalwords)
%
% LDA_LIK computes the log-likelihood of the whole corpus 
%


Pz_d = diag(1./sum(gammas, 2)) * gammas;
Pw_z = diag(1./sum(beta', 2)) * beta';

loglik = 0.0;
for i=1:length(d),
    doc = d{i};
    loglik = loglik + log(1/length(d)) ...
        + sum(doc.cnt.*log(Pz_d(i,:)*Pw_z(:, doc.id)));
end
perwd_loglik = loglik / totalwords;
