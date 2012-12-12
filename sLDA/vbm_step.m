function vbm_step(docs, E_A, E_AA)
%
%   VBM_STEP achieves the M-step of variational bayesian EM
%   inference method.
%
%   Input variable:
%       docs --> one or more documents information used to
%           update model parameters.
%       E_A --> the expectation of A.
%       E_AA --> the expectation of At*A.
%
%   Date: 12/12/2012


global model;

% update Beta
model.beta = normalize(model.betas', 2);

% Note, we fix alpha accroding to the original paper for simplicity.

y = docs.rate';
E_AA_inv = inv(E_AA);
% update regression parameters, i.e., eta, sigma.
model.eta = E_AA_inv*E_A'*y;
model.sigma = (y'*y-y'E_A*E_AA_inv*E_A'*y)/docs.docnum;
