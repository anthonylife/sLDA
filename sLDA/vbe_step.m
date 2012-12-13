function [betas, E_Ai, E_AA] = vbe_step(doc, dicwordnum, E_AA, vbe_maxIter)
%
%   VBE_STEP achieves the E-step of variational bayesian EM
%   inference method.
%
%   Input variable:
%       doc --> current training document and many useful
%           statistic information.
%       dicwordnum --> document id index
%       E_AA --> expectation of At*A.
%       vbe_maxIter --> maximal number of iterations for VBE-step 
%
%   Output variable:
%       betas --> word topic variational parameter for each
%           document
%
%   Date: 12/12/2012
%


if nargin < 4,
    vbe_maxIter = 20;
end

global model;
betas = repmat(1/model.K, dicwordnum, model.K);
docIdx = doc.id;
for i=1:vbe_maxIter,
    gammas = model.alpha + sum(diag(doc.word)*betas, 1);
    
    % The influence of new parameters on updating beta
    npara_part1 = repmat(doc.rate/(doc.docwordnum*model.sigma)*...
        model.eta(1:end-1)' - model.eta(1:end-1)'.*model.eta(1:end-1)'...
        /(2*doc.docwordnum^2*model.sigma), dicwordnum, 1);
    npara_part2 = 2*(repmat(sum(betas, 1), dicwordnum, 1)...
        - betas)*model.eta(1:end-1)*model.eta(1:end-1)'...
        /(2*doc.docwordnum^2*model.sigma);
    npara_part = npara_part1 - npara_part2;

    betas = normalize((model.beta'*diag(exp(psi(model.gammas(docIdx,...
        :)))).*exp(npara_part)), 2);
    
    if (i>1) && converged(model.gammas(docIdx,:), gammas, 1.0e-2),
        model.gammas(docIdx,:) = gammas;
        break;
    end
    model.gammas(docIdx,:) = gammas;
end

if nargin > 2,
    betas_sum = sum(diag(doc.word)*betas, 1);
    E_Ai = [betas_sum./doc.docwordnum, 1];  % additional dimension for bias
    temp_E_AA = repmat(0.0, model.K+1, model.K+1);
    for i=1:dicwordnum,     % Two loops --> O(N)
        for j=1:doc.word(i),
            temp_E_AA = temp_E_AA + [betas(i,:), 1]'*([betas_sum, ...
                doc.docwordnum]-[betas(i,:), 1]) + diag([betas(i,:), 1]);
        end
    end
    temp_E_AA = temp_E_AA ./ doc.docwordnum^2;
    E_AA = E_AA + temp_E_AA;
end
