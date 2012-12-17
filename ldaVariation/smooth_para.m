function betas = smooth_para(betas, smooth_val)
%
%   SMOOTH_PARA smooth the words in the test set while not occur in
%   the training set and avoid 'NaN' value
%
%   Date: 12/15/2012


if nargin < 2,
    smooth_val = 1e-10;
end

ids = find(betas==0);
if length(ids) > 0,
    betas(find(betas==0)) = smooth_val;
    betas = mnormalize(betas, 2);
end
