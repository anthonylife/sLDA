function nm_para = mynormalize(para, d)
%
%   NORMALIZE do normalization for tensor(1-2 dimension) accroding
%   to the specified dimension 'd'.
%
%   Input variable:
%       para --> parameters need to be normalized.
%       d --> specified dimension to be normalized.
%
%   Output variable:
%       nm_para --> normalized parameters.
%
%   Date: 12/12/2012

if nargin < 2,
    d = 1;
end

nm_const = sum(para, d);

if d == 1,
    nm_para = para * diag(1./nm_const);
elseif d == 2,
    nm_para = diag(1./nm_const) * para;
end
