function oldFigures = captureFigures(oldHandles)
%CAPTUREFIGURES	Return figure information for later call to compareFigures
%   OLDFIGURES contains the information that can later be passed to
%   the compareFigures function

% Copyright 1984-2017 The MathWorks, Inc.

% The publishing tools use this.

% Call drawnow here to flush any changes/events that may have been
% triggered if the last loop of takepicture triggered a print.
% This drawnow could be taken out if the print of a uiflowcontainer does
% not trigger a resize (G354913).  It takes two.
drawnow;
drawnow;

% A structure representing the graphics hierarchy, starting with figures.
if nargin == 0
    oldHandles = allchild(0);
    oldHandles = flipud(oldHandles);
end
numHandles = numel(oldHandles);
data = handle2struct([]);
oldFigures.data = data;

% Recursively visit each node, modifying or removing it where appropriate.
toRemove = false(1, numHandles);
for k = 1:numHandles
    oldFigures.data(k).handle = oldHandles(k);
    oldFigures.data(k).properties = getToken(oldHandles(k));
    toRemove(k) = isequal(get(oldHandles(k),'Visible'),'off');
end
oldFigures.data(toRemove) = [];

% Since HANDLE2STRUCT([]) returns an empty structure of the appropriate
% form, we don't need to worry about compareFigures seeing differences
% between different kinds of empty structures.  (See below, in VISIT.)

% The "id" for graphics objects is the handle.
oldFigures.id = [oldFigures.data.handle];

end
