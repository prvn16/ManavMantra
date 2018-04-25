function hMode = getuimode(hFig,name)
% This function is undocumented and will change in a future release

%GETUIMODE Returns a handle to a mode in the given figure.
%   MODE = GETMODE(FIG,NAME) returns the mode with the unique name
%   specified by NAME for the figure FIG.
%
%   See also UIMODE, HASUIMODE, ACTIVATEUIMODE, ISACTIVEUIMODE

%   Copyright 2006-2007 The MathWorks, Inc.

hManager = uigetmodemanager(hFig);
hMode = getMode(hManager,name);