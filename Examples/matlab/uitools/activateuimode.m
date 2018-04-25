function activateuimode(hFig,name)
% This function is undocumented and will change in a future release

%ACTIVATEUIMODE Starts the execution of a mode.
%   ACTIVATEUIMODE(FIG,NAME) will start the mode with the given 
%   name in the given figure. When a mode is started, any other 
%   active mode is stopped. If NAME is the empty string, then any
%   active mode will be stopped and no mode will be active.
%
%   See also UIMODE, GETUIMODE, HASUIMODE, ISACTIVEUIMODE

%   Copyright 2006-2009 The MathWorks, Inc.

hManager = uigetmodemanager(hFig);

% If "name" is empty, then turn on the default mode.
if isempty(name)
    newName = get(hManager,'DefaultUIMode');
    hMode = getMode(hManager,newName);
    set(hManager,'CurrentMode',hMode);
    return;
end
hMode = getMode(hManager,name);
if isempty(hMode)
    error(message('MATLAB:activateuimode:InvalidMode'));
else
    set(hManager,'CurrentMode',hMode);
end