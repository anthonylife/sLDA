function n = features(m)
% n = features(m)
% returns a maximum feature id contained in the feature matrix m.
% m : feature matrix loaded by fmatrix().
% $Id: features.m,v 1.1 2004/11/08 08:31:05 dmochiha Exp $
n = 0;
for d = m
  for id = d{:}.id
    if id > n
      n = id;
    end
  end
end
