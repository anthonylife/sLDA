%COMPLIKEHOOD compute the log-likelihood of generating whole corpus

function loghood = compLoghood()
global Corp; 
global Pz; global Pd_z; global Pw_z;

% Tradeoff between memory and speed
loghood = 0.0;
for i=1:Corp.nw
    loghood = loghood + Corp.X(:,i)'*log(Pd_z*diag(Pz)*Pw_z(i,:)');
end

