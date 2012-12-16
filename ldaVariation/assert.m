function assert(b)
% assert(b) asserts that the condition b is always true.
% $Id: assert.m,v 1.1 2004/10/20 10:35:15 dmochiha Exp $
if b == true
  return;
else
  error('assertion failed.');
end
