function [llhood, perword_llhood]= getllhood(docs)
%
%   GETLLHOOD calculates the corpus words likelihood using the lower bound
%   just like <Latent Dirichlet Allocation, David Blei, 2003, JMLR>.
%
%   Input variable:
%       docs --> a collection of documents, such as trianing and test set.   
%
%   Output variable:
%       llhood --> log-likelihood of the whole corpus words.
%       perword_llhood --> per-word log-likelihood.
%
%   Date: 12/12/2012


global model;

llhood = 0;
for i=1:docs.docnum,
    digamma_diff = psi(model.gammas(i,:))-psi(sum(model.gammas(i,:)));
    temp = loggamma(sum(model.alpha)) - sum(loggamma(model.alpha))...
        + sum((model.alpha-1).*digamma_diff)...
        + sum(diag(docs.doc(i).word)*model.betas(docs.doc(i).word_id,:),1)*digamma_diff'...
        + sum(model.betas(docs.doc(i).word_id,:).*log(model.beta(:,docs.doc(i).word_id))', 2)'...
        * docs.doc(i).word'...
        - loggamma(sum(model.gammas(i,:)))...
        + sum(loggamma(model.gammas(i,:)))... 
        - sum((model.gammas(i,:)-1).*digamma_diff)...
        - sum(model.betas(docs.doc(i).word_id,:).*log(model.betas(docs.doc(i).word_id,:)), 2)'...
        * docs.doc(i).word';
    llhood = temp + llhood;
end
perword_llhood = llhood / docs.totalwords;
