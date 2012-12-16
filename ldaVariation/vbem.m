function [alpha,q] = vbem(d,beta,alpha0,emmax)
% [alpha,q] = vbem(d,beta,alpha0,[emmax])
% calculates a document and words posterior for a document d.
% alpha  : Dirichlet posterior for a document d
% q      : (L * K) matrix of word posterior over latent classes
% d      : document data
% alpha0 : Dirichlet prior of alpha
% emmax  : maximum # of VB-EM iteration.
% $Id: vbem.m,v 1.5 2004/11/08 12:42:18 dmochiha Exp $
if nargin < 4
  emmax = 20;
end
l = length(d.id);
k = length(alpha0);
q = zeros(l,k);
nt = ones(1,k) * l / k;
pnt = nt;
for j = 1:emmax
  % vb-estep
  q = mnormalize(beta(d.id,:) * diag(exp(psi(alpha0 + nt))),2);
  % Here, q is equal to the standard representation of phi
  
  % vb-mstep
  nt = d.cnt * q;
  % converge?
  if (j > 1) && converged(nt,pnt,1.0e-2)
    break;
  end
  pnt = nt;
end
alpha = alpha0 + nt;
