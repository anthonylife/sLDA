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
model.betas(doc.word_id,:) = model.betas(doc.word_id,:) + betas(doc.word_id,:);
