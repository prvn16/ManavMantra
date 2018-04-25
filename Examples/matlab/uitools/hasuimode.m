function flag = hasuimode(hFig,name)
% This function is undocumented and will change in a future release

%HASUIMODE Returns whether a mode exists for the given figure.
%   FLAG = HASUIMODE(FIG,NAME) will evaluate to true if the mode with the
%   unique name specified by NAME exists in the figure FIG.
%
%   See also UIMODE, GETUIMODE, ACTIVATEUIMODE, ISACTIVEUIMODE

%   Copyright 2006-2010 The MathWorks, Inc.

hManager = uigetmodemanager(hFig);
hMode = getMode(hManager,name);
if isempty(hMode)
    flag = false;
else
    flag = true;
end