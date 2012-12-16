function p = diff_vec(u,v)
% p = diff_vec(u,v)
% Returns a difference ratio of v, w.r.t. u.
% $Id: diff_vec.m,v 1.2 2004/11/12 12:45:01 dmochiha Exp $
p = norm(u - v) / norm(u);
