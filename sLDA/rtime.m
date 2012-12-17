function s = rtime(t)
% s = rtime(t)
% returns a human readable form of seconds t.
% $Id: rtime.m,v 1.2 2004/10/25 02:05:54 dmochiha Exp $
hour = floor(t / 60 / 60);
min = floor(mod(t,60 * 60) / 60);
sec = floor(mod(t,60));
s = sprintf('%2d:%02d:%02d',hour,min,sec);
