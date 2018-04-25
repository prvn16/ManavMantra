function updateWordTextAndXPos(ntx)
% Update x-position of word length (WL) line text
%
% Called by updateThresholds()
% Does NOT touch y-pos of text (except bug fix-ups)

%   Copyright 2010 The MathWorks, Inc.

% Prepare fix for units wander-bug
set(ntx.htWordSpan,'Units','char');
psave = get(ntx.htWordSpan,'Position'); % cache pos, char units
set(ntx.htWordSpan,'Units','data'); % switch to data units
pos = get(ntx.htWordSpan,'Position'); % in data units

% Construct display string
% Alt 2:
%  - include extra bits in word length count, don't separate them
%    this way, WL is simply the sum of IL+FL
%  - call out sign bit in gray, separately from WL, so WL=IL+FL and the
%    sign bit is tracked separately

% Include extra bits in bit counts:
[~,~,wordBits,~] = getWordSize(ntx,true);
str = sprintf('WL=%d',wordBits);

set(ntx.htWordSpan,'String',str); % preliminary update to measure extent

% Adjust x-position of word length text
%   based on x-extent of rendered text
ext = get(ntx.htWordSpan,'Extent'); % relies on being in data units
strWidth = ext(3); % string width in x-axis data units
xWordSpan = get(ntx.hlWordSpan,'XData'); % span between under/overflow lines
wordSpan = xWordSpan(2) - xWordSpan(1); % width of wordspan line
if strWidth > wordSpan
    % Text is too wide to fit in middle "wordspan" region
    % Move it to the underflow or overflow region,
    %   depending upon which region is wider
    xlim = get(ntx.hHistAxis,'XLim'); % overall span of axes
    underWidth = xWordSpan(1) - xlim(1);
    overWidth = xlim(2) - xWordSpan(2);
    if underWidth>overWidth
        % Move to right (underflow region)
        horz = 'left';
        xt = xWordSpan(1); % standard text/line gutter, in data units
        xtAdj = +1.25; % chars to adjust for gutter
    else
        % Move to left (overflow region)
        horz = 'right';
        xt = xWordSpan(2);
        xtAdj = -0.5; % chars to adjust for gutter
    end
else
    horz = 'center';
    % xt: text x-position
    xt = (ntx.LastUnder+ntx.LastOver)/2 - ntx.BarGapCenter;
    xtAdj = 0.5; % unusual that we need offset to center text properly
end
pos(1) = xt;
set(ntx.htWordSpan, ...
    'Position',pos, ...
    'BackgroundColor','none', ...
    'HorizontalAlignment',horz);
set(ntx.htWordSpan,'Units','char')

% fix-up for y wander bug
pos = get(ntx.htWordSpan,'Position');
pos(1) = pos(1)+xtAdj; % apply adjustment for gutter spacing
pos(2) = psave(2);
set(ntx.htWordSpan,'Position',pos);
