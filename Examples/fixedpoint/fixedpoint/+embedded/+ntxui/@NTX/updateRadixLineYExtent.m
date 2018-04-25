function updateRadixLineYExtent(ntx)
% Update RadixLine y-extent.
%
% Check if overflow and underflow lines are both on the "same side"
% of the radix line.  If so, lengthen radix line height to top of axis
% since the wordspan line no longer intersects it.

%   Copyright 2010 The MathWorks, Inc.

if (ntx.LastUnder >= ntx.RadixPt) || (ntx.LastOver  <= ntx.RadixPt)
    ylim = get(ntx.hHistAxis,'YLim'); % height in data units
    yd = [0 ylim(2)];          % Take it up to top of axis
else
    % set radix line height to touch wordspan horiz line
    yd = [0 ntx.yWordSpan];
end
set(ntx.hlRadixLine,'YData',yd);
