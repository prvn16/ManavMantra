function y = validOverflowXDrag(ntx,v)
% True if proposed x-axis bit weight value is valid
% in the sense that the threshold line can be updated
% to that value.
%
% v is a "conceptual" cursor value, where 3 means a threshold at 2^3, and
% would be graphically depicted at 3-BarGapCenter (or 2.875).  We need to
% subtract BarGapCenter from graphical values (such as xlim) to determine
% the conceptual position in order to compare these values properly.
%
% By default, graphicalVal=true.
%
% Constrain to ...
%   * not move past upper x-axis limit
%   * not move past underflow thresh

%   Copyright 2010 The MathWorks, Inc.

xlim = get(ntx.hHistAxis,'XLim');
y = (v-ntx.BarGapCenter <= xlim(2)) && (v > ntx.LastUnder);
