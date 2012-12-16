function x = normalize(v)
% x = normalize(v)
% Normalize a vector v to sum to 1.
% $Id: normalize.m,v 1.1 2004/09/14 04:33:05 dmochiha Exp $
x = v / sum(v);
