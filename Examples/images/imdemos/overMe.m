function overMe(hFigure, currentPoint)
%overMe Set figure pointer depending on pointer location.
%   overMe is a function used by one of the examples in the documentation
%   for iptSetPointerBehavior.  overMe(hFigure, currentPoint) sets the
%   hFigure mouse pointer to be either 'topr', 'topl', 'botr', 'botl',
%   depending on whether currentPoint is in the top right, top left, bottom
%   right, or bottom left of the hFigure's current axes.

%   Copyright 2005-2009 The MathWorks, Inc.

hAxes = get(hFigure, 'CurrentAxes');

% Get the axes position in pixel units.
oldUnits = get(hAxes, 'Units');
set(hAxes, 'Units', 'pixels');
axesPosition = get(hAxes, 'Position');
set(hAxes, 'Units', oldUnits);

x_middle = axesPosition(1) + 0.5*axesPosition(3);
y_middle = axesPosition(2) + 0.5*axesPosition(4);

x = currentPoint(1,1);
y = currentPoint(1,2);

if (x > x_middle)
    if (y > y_middle)
        pointer = 'topr';
    else
        pointer = 'botr';
    end
else
    if (y > y_middle)
        pointer = 'topl';
    else
        pointer = 'botl';
    end
end

set(hFigure, 'Pointer', pointer);
