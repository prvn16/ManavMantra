function y = validUnderflowXDrag(ntx,v)
% True if proposed x-axis bit weight value is valid
% in the sense that the threshold line can be updated
% to that value.
%
% Constrain to ...
%   * not move past lower axis limit
%   * not move past overflow threshold

%   Copyright 2010 The MathWorks, Inc.

xlim = get(ntx.hHistAxis,'XLim');
y = (v-ntx.BarGapCenter >= xlim(1)) && (v < ntx.LastOver);
