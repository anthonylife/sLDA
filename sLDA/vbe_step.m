function [E_Ai, E_AA] = vbe_step(doc, dicwordnum, E_AA, vbe_maxIter)
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
%       E_Ai --> Expectation of A which used for optimizing elta and sigma
%       E_AA --> Similar as the previous one
%
%   Date: 12/12/2012
%


if nargin < 4,
    vbe_maxIter = 20;
end

global model;
global betas;

docIdx = doc.id;

% Reinitialization for each document in every turn
betas(:,:) = 1/model.K;
model.gammas(docIdx,:) = model.alpha ...
    + repmat(doc.docwordnum/model.K, 1, model.K);

for i=1:vbe_maxIter,
    % The influence of new parameters on updating beta
    %doc_llhood = getdocllhood(doc, 'train');
    %fprintf('document %d, likelihood: %f\n', doc.id, doc_llhood);
    
    npara_part1 = repmat(doc.rate/(doc.docwordnum*model.sigma)*...
        model.eta(1:end-1)' - model.eta(1:end-1)'.*model.eta(1:end-1)'...
        /(2*doc.docwordnum^2*model.sigma), length(doc.word_id), 1);
    
    npara_part2 = 2*(repmat(sum(diag(doc.word)*betas(doc.word_id,:),1),length(doc.word_id),1)...
        - diag(doc.word)*betas(doc.word_id,:)) * model.eta(1:end-1)...
        * model.eta(1:end-1)' / (2*doc.docwordnum^2*model.sigma);
    
    betas(doc.word_id,:) = normalize(model.beta(:,doc.word_id)'...
        *diag(exp(psi(model.gammas(docIdx,:))))...
        .*exp(npara_part1 - npara_part2), 2);
    
    %smooth_para('betas', doc.word_id);

    gammas = model.alpha + doc.word*betas(doc.word_id,:);
    if i> 1 && converged(model.gammas(docIdx,:), gammas, 1.0e-4),
        model.gammas(docIdx,:) = gammas;
        break;
    end
    model.gammas(docIdx,:) = gammas;
end


if nargin > 2,
    betas_sum = sum(diag(doc.word)*betas(doc.word_id,:), 1);
    E_Ai = [betas_sum./doc.docwordnum, 1];  % additional dimension for bias
    temp_E_AA = repmat(0.0, model.K+1, model.K+1);
    for i=1:length(doc.word),     % Two loops --> O(N)
        for j=1:doc.word(i),
            temp_E_AA = temp_E_AA + [betas(doc.word_id(i),:), 1]'*([betas_sum, ...
                doc.docwordnum]-[betas(doc.word_id(i),:), 1])...
                + diag([betas(doc.word_id(i), :)'; 1]);
        end
    end
    temp_E_AA = temp_E_AA ./ doc.docwordnum^2;
    E_AA = E_AA + temp_E_AA;
else
    E_Ai = 0;
    E_AA = 0;
end
