%COMPPERPLEX compute perplexity of whole corpus.

function perplex = compPerplex(loghood)
global Corp;
global Pz; global Pw_z; global Pd_z;

perplex = exp(-loghood/sum(sum(Corp.X)));
%loghood = 0.0;
%for i=1:Corp.nd,
%    loghood = loghood + prod(sum(Corp.X(i,:)*Pw_z, 2));
%end
%perplex = exp(-loghood/Corp.N);
