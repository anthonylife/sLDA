function tag = converged(vec1, vec2, threshold)
%
%   CONVERGED judges whether the difference of the two tensors
%   (1-2 dimension) is below the specified threshold.
%
%   Input Variable:
%       vec1 --> the first vector.
%       vec2 --> the second vector.
%       threshold --> specified threshold.
%
%   Date:12/12/2012


if nargin < 3,
    threshold = 1.0e-2;
end

dim = size(vec1);
if dim(1) > 1,
    dim = 2;
else,
    dim = 1;
end

diff = abs(vec1 - vec2);
for i=1:dim,
    diff = sum(diff);
end

if diff < threshold,
    tag = true;
else
    tag = false;
end
