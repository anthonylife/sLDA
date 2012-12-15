function [corp_llhood, perword_llhood]= getcorpllhood(docs, choice)
%
%   GETLLHOOD calculates the corpus words likelihood using the lower bound
%   just like <Latent Dirichlet Allocation, David Blei, 2003, JMLR>.
%
%   Input variable:
%       docs --> a collection of documents, such as trianing and test set.   
%       choice --> whether used in training or evaluation.
%
%   Output variable:
%       llhood --> log-likelihood of the whole corpus words.
%       perword_llhood --> per-word log-likelihood.
%
%   Date: 12/12/2012


global model;
global doc_llhood;

corp_llhood = 0;
for i=1:docs.docnum,
    doc_llhood = getdocllhood(docs.doc(i), choice);
    corp_llhood = doc_llhood + corp_llhood;
    if isnan(doc_llhood),
        pause;
        i
    end
end
perword_llhood = corp_llhood / docs.totalwords;
