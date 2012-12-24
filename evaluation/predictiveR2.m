function pR2 = predictiveR2(real_Y, pre_Y)
%
%   PREDICTIVER2 adopts the metric of 'predictive R2' for
%   regression task.
%
%   Input variable:
%       real_Y --> original real value
%       pre_Y --> predicted value
%
%   Date: 12/12/2012

mean_Y = sum(real_Y)/length(real_Y);
pR2 = 1 - sum((real_Y-pre_Y).^2)/sum((real_Y-mean_Y).^2);
