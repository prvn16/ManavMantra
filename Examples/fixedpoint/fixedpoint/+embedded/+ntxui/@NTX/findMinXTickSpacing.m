function s = findMinXTickSpacing(ntx,xMin,xMax)
% Return minimum spacing of x-tick labels given min and max x-axis limits
%
% Can return negative spacing under degenerate condition of an axis whose
% height is zero or less than zero

%   Copyright 2010 The MathWorks, Inc.

% Find widest tick label we might render - the actual extent of the text
% It's either the min or max x-axis limit
% e.g., min may be '2^-10' while max may be '2^32'

ht = ntx.hOffscreenText;

labelFmt = '2^{%d}';
set(ht,'Units','data');
set(ht,'String',sprintf(labelFmt,xMin));
ext1 = get(ht,'Extent');
set(ht,'String',sprintf(labelFmt,xMax));
ext2 = get(ht,'Extent');

% Determine minimum spacing of x-ticks
% This is in "x-axis data units"
% If this is 1.0, we can put a tick at increments of 1
% If this is 4.0, we can put ticks at increments of 4
maxWidth = max(ext1(3),ext2(3)); % max width of text labels, data units
s = ceil(maxWidth);
