function selHandles = createMCOSSelectionHandles(h)
% This method is undocumented and will be removed in a future release.

%   Copyright 2012 The MathWorks, Inc.

% Create matlab.graphics.internal.SelectionHandles parented to the
% specified object.

if nargin>=1
    selHandles =  matlab.graphics.internal.SelectionHandles(h);
else
    selHandles = matlab.graphics.internal.SelectionHandles.empty;
end