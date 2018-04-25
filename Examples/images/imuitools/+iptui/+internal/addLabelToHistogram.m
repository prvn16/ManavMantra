function addLabelToHistogram(hAx, label)
%addLabelToHistogram   Place label next to a histogram.

%   Copyright 2013-2015 The MathWorks, Inc.

% Create the text label.
xLim = double(get(hAx, 'XLim'));
yLim = double(get(hAx, 'YLim'));

hText = text(xLim(1), yLim(2), label, 'parent', hAx);
set(hText, 'FontSize', 14)
set(hText, 'FontWeight', 'bold')

% Align the text to be to the left of the axes top, just below.
set(hText, 'HorizontalAlignment', 'right')
set(hText, 'VerticalAlignment', 'top')

% Place the text label just outside the axes by moving one-character width
% to the left.
default = get(hText, 'Units');
set(hText, 'Units', 'character')

pos = get(hText, 'Position');
pos(1) = pos(1) - 1;

% CHange the units back to the default.
set(hText, 'Position', pos);
set(hText, 'Units', default);

end
