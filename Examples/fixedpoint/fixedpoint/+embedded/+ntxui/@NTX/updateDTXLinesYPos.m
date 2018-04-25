function updateDTXLinesYPos(ntx)
% Set height of WordSpan line (yws) to be just below the wordspan text,
% and above the frac/int text.

%   Copyright 2010 The MathWorks, Inc.

% Leave additional 15% of text height as a vertical gutter between
% wordspan text and wordspan line.
psave = get(ntx.htWordSpan,'Position'); % save for wander bug-fix
set(ntx.htWordSpan,'Units','data');
ext = get(ntx.htWordSpan,'Extent'); % extent of text, in data units
yws = ext(2) - 0.15*ext(4);  % yBottom, minus 15% of yHeight
set(ntx.htWordSpan,'Units','char','Position',psave);

% Retain yWordSpan for other scaling code
ntx.yWordSpan = yws;

% Update word span, radix, threshold lines
ylim = get(ntx.hHistAxis,'YLim');    % height in data units
set([ntx.hlUnder ntx.hlOver],'YData',[0 ylim(2)]);
set(ntx.hlWordSpan,'YData',[yws yws]);

% Height of radix line must be conditionally set,
% based on where threshold cursors are located
updateRadixLineYExtent(ntx);
