function betas = accum_beta(betas,q,t)
% betas = accum_beta(betas,q,t)
% accumulates word posteriors to latent classes.
% betas : (V * K) matrix of summand
% q     : (l * K) matrix of word posteriors
% t     : document of struct array
% $Id: accum_beta.m,v 1.5 2004/10/26 02:24:38 dmochiha Exp $
% Sat Oct 23 16:50:45 JST 2004 dmochiha@slt.atr.jp
betas(t.id,:) = betas(t.id,:) + diag(t.cnt) * q;
