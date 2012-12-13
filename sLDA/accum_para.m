function accum_para(doc, wordNum)
%
%   ACCUM_PARA accumulates betas from each document and then
%   normalizes them.
%
%   Input variable:
%       doc --> current document       
%       wordNum --> total number of words' dictionary
%
%   Date: 12/12/2012


global model;
global betas;

betas(doc.word_id,:) = diag(doc.word)*betas(doc.word_id,:);
betas(setdiff([1:wordNum], doc.word_id),:) = 0;
model.betas = model.betas + betas;
