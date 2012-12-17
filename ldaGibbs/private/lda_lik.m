function [logllhood, perwd_lik] = lda_lik()
% LDA_LIK compute the log-likelihood of the whole corpus.

global Corp; global Pz_d; global Pw_z;
global Model;

logllhood = 0.0;
for i=1:Corp.nd,
    logllhood = logllhood + log(1/Corp.nd) + sum(log(Pz_d(i,:)*Pw_z(Corp.doc(i).wordid, :)'));
end
perwd_lik = logllhood / Corp.totalwordnum;
