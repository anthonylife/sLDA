function betas = vbe_step(doc, dicwordnum, vbe_maxIter)
%
%   VBE_STEP achieves the E-step of variational bayesian EM
%   inference method.
%
%   Input variable:
%       doc --> current training document and many useful
%           statistic information.
%       dicwordnum --> document id index
%       vbe_maxIter --> maximal number of iterations for VBE-step 
%
%   Output variable:
%       betas --> word topic variational parameter for each
%           document
%
%   Date: 12/12/2012
%


if nargin < 3,
    vbe_maxIter = 20;
end

global model;
betas = repmat(1/model.K, dicwordnum, model.K);

for i=1:vbe_maxIter,
    gammas = model.alpha + sum(diage(doc.word)*betas, 1)------;
    
    % For new parameter
    npara_part1 = repmat(doc.rate/(doc.docwordnum*model.sigma)*...
        model.eta' - model.eta'.*model.eta'/(2*doc.docwordnum^2*...
        model.sigma), dicwordnum, 1);
    npara_part2 = 2*(repmat(sum(betas, 1), dicwordnum, 1)...
        - betas)*model.eta*model.eta'/(2*doc.docwordnum^2*model.sigma);
    npara_part = npara_part1 + npara_part2;

    betas = normalize((model.beta'*diag(exp(psi(model.gammas(docIdx,...
        :))))*exp(npara_part)), 2);
    
    if (i>1) && converged(model.gammas(docIdx,:), gammas, 1.0e-2),
        model.gammas(docIdx,:) = gammas;
        break;
    end
    model.gammas(docIdx,:) = gammas;
end
