function [alpha,beta] = ldamain(train,k,emmax,demmax)
% wrapper of Latent Dirichlet Allocation, standard model.
% [alpha,beta] = ldamain(train,k,[emmax,demmax])
% $Id: ldamain.m,v 1.1 2004/11/08 12:41:58 dmochiha Exp $
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
d = fmatrix(train);
[alpha,beta] = lda(d,k,emmax,demmax);
