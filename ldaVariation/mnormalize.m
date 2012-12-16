function x = mnormalize(m,d)
% x = mnormalize(m,d)
% normalizes a matrix m along the dimension d.
% m : matrix
% d : dimension to normalize (default 1)
% $Id: mnormalize.m,v 1.1 2004/10/21 07:09:01 dmochiha Exp $
if nargin < 2
  d = 1;
end
v = sum(m,d);
if d == 1
  x = m * diag(1 ./ v);
elseif d == 2
  x = diag(1 ./ v') * m;
else
  error('mnormalize: dimension must be 1 or 2.');
end
