function doc_llhood = getdocllhood(doc, choice)

global model;
global betas;

doc_id = doc.id;
digamma_diff = psi(model.gammas(doc_id,:))-psi(sum(model.gammas(doc_id,:)));
doc_llhood = loggamma(sum(model.alpha)) - sum(loggamma(model.alpha))...
    + sum((model.alpha-1).*digamma_diff)...
    + sum(diag(doc.word)*betas(doc.word_id,:),1)*digamma_diff'...
    + sum(betas(doc.word_id,:).*log(model.beta(:,doc.word_id))', 2)'...
    * doc.word' - loggamma(sum(model.gammas(doc_id,:)))...
    + sum(loggamma(model.gammas(doc_id,:)))... 
    - sum((model.gammas(doc_id,:)-1).*digamma_diff)...
    - sum(betas(doc.word_id,:).*log(betas(doc.word_id,:)), 2)'...
    * doc.word';

% Debug
if isnan(doc_llhood)
    disp('traditional item');
    loggamma(sum(model.alpha)) - sum(loggamma(model.alpha)) + sum((model.alpha-1).*digamma_diff)
    sum(diag(doc.word)*betas(doc.word_id,:),1)*digamma_diff'
    sum(betas(doc.word_id,:).*log(model.beta(:,doc.word_id))', 2)' * doc.word'
    -loggamma(sum(model.gammas(doc_id,:))) + sum(loggamma(model.gammas(doc_id,:)))
    sum((model.gammas(doc_id,:)-1).*digamma_diff)
    -sum(betas(doc.word_id,:).*log(betas(doc.word_id,:)), 2)'* doc.word'
    for j=doc.word_id
        sum(betas(j,:))
        log(betas(j,:))
        find(betas(j,:)==0)
        pause;
    end
    pause;
end
%doc_llhood
% for the response variable in sLDA
doc_llhood = doc_llhood - 1/2*log(2*pi*model.sigma)...
    -doc.rate^2/(2*model.sigma);
if isnan(doc_llhood)
    disp('new item 1');
    pause;
end

switch choice,
case 'eval',
    betas_sum = sum(diag(doc.word)*model.betas(doc.word_id,:), 1);
    E_Z = [betas_sum./doc.docwordnum, 1];  % additional dimension for bias
    E_ZZ = repmat(0.0, model.K+1, model.K+1);
    for i=1:length(doc.word),     % Two loops --> O(N)
        for j=1:doc.word(i),
            E_ZZ = E_ZZ + [model.betas(doc.word_id(i),:), 1]'*([betas_sum, ...
                doc.docwordnum]-[model.betas(doc.word_id(i),:), 1])...
                + diag([model.betas(doc.word_id(i), :)'; 1]);
        end
    end

case 'train',
    betas_sum = sum(diag(doc.word)*betas(doc.word_id,:), 1);
    E_Z = [betas_sum./doc.docwordnum, 1];  % additional dimension for bias
    E_ZZ = repmat(0.0, model.K+1, model.K+1);
    for i=1:length(doc.word),     % Two loops --> O(N)
        for j=1:doc.word(i),
            E_ZZ = E_ZZ + [betas(doc.word_id(i),:), 1]'*([betas_sum, ...
                doc.docwordnum]-[betas(doc.word_id(i),:), 1])...
                + diag([betas(doc.word_id(i), :)'; 1]);
        end
    end

otherwise,
    error('Invalid choice.');
end

doc_llhood = doc_llhood + (2*doc.rate*model.eta'*E_Z'-model.eta'*E_ZZ*model.eta)...
    ./(2*model.sigma);

if isnan(doc_llhood)
    disp('new item 2');
    pause;
end

