function alpha = newton_alpha (gammas,maxiter,ini_alpha)
% alpha = newton_alpha (gammas,[maxiter])
% Newton-Raphson iteration of LDA Dirichlet prior.
% gammas  : matrix of Dirichlet posteriors (M * k)
% maxiter : # of maximum iteration of Newton-Raphson
% $Id: newton_alpha.m,v 1.2 2004/10/09 08:34:54 dmochiha Exp $
[M,K] = size(gammas);

if ~(M > 1)
  alpha = gammas(1,:);
  return;
end
if nargin < 3
  ini_alpha = mean(gammas) / K; % initial point
  if nargin < 2
    maxiter = 20;
  end
end

l = 0;
g = zeros(1,K);
pg = sum(psi(gammas),1) - sum(psi(sum(gammas,2)));
alpha = ini_alpha;
palpha = zeros(1,K);

for t = 1:maxiter
  l = l + 1;
  alpha0 = sum(alpha);
  g = M * (psi(alpha0) - psi(alpha)) + pg;
  h = - 1 ./ psi(1,alpha);
  hgz = h * g' / (1 / psi(1,alpha0) + sum(h));
  
  for i = 1:K
    alpha(i) = alpha(i) - h(i) * (g(i) - hgz) / M;
  end
  if any(alpha < 0)
    alpha = newton_alpha(gammas,maxiter,ini_alpha / 10); % try again!
    return;
  end
  
  if (l > 1) && converged(alpha,palpha,1.0e-4)
    break;
  end
  palpha = alpha;
end

