%COMPLIKEHOOD compute the log-likelihood of generating whole corpus

function loghood = compLoghood()
global Corp; 
global Pz; global Pd_z; global Pw_z;

% Tradeoff between memory and speed
loghood = 0.0;
for i=1:Corp.nw
    loghood = loghood + Corp.X(:,i)'*log(Pd_z*diag(Pz)*Pw_z(i,:)');
end

% Following way will speed the program. However, it will generate a
%   an intermediate huge matrix, with the size of w(word)*d(doc)
%{
loghood = sum(sum(Corp.X' .* log(Pw_z * diag(Pz) * Pd_z' + 1)));
loghood = full(loghood);
%}
