function smooth_para(choice, word_id, smooth_val)
%
%   SMOOTH_PARA smooth the words in the test set while not occur in
%   the training set and avoid 'NaN' value
%
%   Date: 12/15/2012


if nargin < 3,
    smooth_val = 1e-100;
end

switch choice,
case 'beta'
    global model;
    ids = find(model.beta==0);
    if length(ids) > 0,
        model.beta(find(model.beta==0)) = smooth_val;
        model.beta = normalize(model.beta, 2);
    end
case 'betas'
    global betas;
    ids = find(betas(word_id,:) == 0);
    if length(ids) > 0,
        temp = betas(word_id,:);
        temp(ids) = smooth_val;
        betas(word_id,:) = normalize(temp, 2);
    end
otherwise,
    error('Invailid choice.');
end
