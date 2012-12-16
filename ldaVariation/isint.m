function b = isint(n)
% b = isint(n)
% tests that n is an integer.
% $Id: isint.m,v 1.1 2004/10/20 10:33:56 dmochiha Exp $
b = ((n - floor(n)) == 0);
