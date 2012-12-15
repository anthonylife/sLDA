function smooth_beta()
%
%   SMOOTH_BETA smooth the words in the test set while not occur in
%   the training set
%
%   Date: 12/15/2012


global model;

if nargin < 1,
    smooth_val = 1e-100;
end

model.beta(find(model.beta==0)) = smooth_val;
model.beta = normalize(model.beta, 2);
