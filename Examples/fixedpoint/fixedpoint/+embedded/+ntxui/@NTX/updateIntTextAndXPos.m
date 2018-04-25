function updateIntTextAndXPos(ntx)
% Update integer-size text and x-position
% Options:
%   1 = Integer length
%   2 = MSB

%   Copyright 2010 The MathWorks, Inc.

dlg = ntx.hBitAllocationDialog;

% Don't include extra bits in intBits, we call them out separately
intBits = getWordSize(ntx);

xq = ntx.LastOver;
radixPt = ntx.RadixPt;
ena = extraMSBBitsSelected(dlg);
if ntx.DTXIntSpanText==1
    if ena
        % Show summation of extra bits separately
        % Show extra bits in gray italics
        s1 = sprintf('IL=%d',intBits);
        s2 = sprintf('%d',dlg.BAILGuardBits);
        str = [s1 '\color{gray}\it+' s2];
    else
        str = sprintf('IL=%d',intBits);
    end
    vert = 'top';
else
    str = sprintf('MSB=2^{%d}',xq-radixPt);
    vert = 'cap';
end
% Initial setup of text to get actual text extent
psave = get(ntx.htIntSpan,'Position');
set(ntx.htIntSpan, ...
    'VerticalAlignment',vert, ...
    'Units','data', ...
    'String',str);

% Adjust int-size text position
pos = get(ntx.htIntSpan,'Position');

% Check if overflow line is less than the radix point
overflowPastRadix = xq < radixPt;
if overflowPastRadix
    placeToSide = true;
else
    ext = get(ntx.htIntSpan,'Extent');
    strWidth = ext(3); % in x-axis data units
    ref = max(radixPt,ntx.LastUnder);
    placeToSide = (strWidth*1.1 > xq-ref); % 10% buffer around string
end
if placeToSide
    % Put text to left of, and flush-right to, overflow cursor
    pos(1) = xq;
    horz = 'right';
    xtAdj = -0.5;
else
    % Center text within cursor-to-center region
    pos(1) = (xq+ref)/2;
    horz = 'center';
    xtAdj = +0.5;
end
set(ntx.htIntSpan, ...
    'Position',pos, ...
    'BackgroundColor','none', ...
    'HorizontalAlignment',horz);
set(ntx.htIntSpan,'Units','char');

% fixup for y wander bug
pos = get(ntx.htIntSpan,'Position');
pos(1) = pos(1) + xtAdj;
pos(2) = psave(2);
set(ntx.htIntSpan,'Position',pos);
