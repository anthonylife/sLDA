function new_betas = accum_para(old_betas, inc_betas, doc)
%
%   ACCUM_PARA accumulates betas from each document and then
%   normalizes them.
%
%   Input variable:
%       old_betas --> accumulated values of betas from the first
%           document to the previous document.
%       inc_betas --> values of betas of current document.
%
%   Output variable:
%       new_betas --> updated betas.
%
%   Date: 12/12/2012


new_betas = old_betas + diag(doc.word)*inc_betas;
