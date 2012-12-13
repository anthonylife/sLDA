function result = loggamma(in_val)
%
%   LOGGAMMA wrap up the normal gamma function for and converts
%   factorial to accumulation to avoid overflow using the property
%   of 'log' operator.
%
%   Date: 12/13/2012


result = 0;
for i=2:in_val-1,
    result = result + log(i);
end
