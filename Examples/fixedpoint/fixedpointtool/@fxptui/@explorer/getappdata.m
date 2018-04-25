function appdata = getappdata(h)
%GETAPPDATA Get the appdata from the block diagram.
%   OUT = GETAPPDATA(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.

appdata = SimulinkFixedPoint.getApplicationData(h.getFPTRoot.getDAObject.getFullName);

% [EOF]
