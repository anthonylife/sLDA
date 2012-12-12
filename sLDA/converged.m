function tag = converged(vec1, vec2, threshold)
%
%   CONVERGED judges whether the difference of the two tensors
%   is below the specified threshold.
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

dim = length(size(vec1));
diff = abs(vec1 - vec2);
for i=1:dim,
    diff = sum(diff);
end

if diff < threshold,
    tag = true;
else
    tag = false;
end
