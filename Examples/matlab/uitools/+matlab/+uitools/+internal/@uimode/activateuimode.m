function activateuimode(hThis,name)
% This function is undocumented and will change in a future release
%   Copyright 2013 The MathWorks, Inc.

%ACTIVATEUIMODE Starts the execution of a composed mode.
%   ACTIVATEUIMODE(MODE,NAME) will start the mode with the given 
%   name in the given figure. When a mode is started, any other 
%   active mode is stopped. 

% The parent mode must be active if a child mode is activated:
if ~hThis.BusyActivating && ~strcmpi(hThis.Enable,'on')
    if isempty(hThis.ParentMode)
        activateuimode(hThis.FigureHandle,hThis.Name);
    else
        activateuimode(hThis.ParentMode,hThis.Name);
    end
end

% If another composed mode is active, disable it:
currMode = hThis.CurrentMode;

if ~isempty(name)
    hMode = getuimode(hThis,name);
    if isempty(hMode)
        error(message('MATLAB:activateuimode:InvalidMode'));
    end
else
    % If a name hasn't been explicitly given, use the default mode.
    % If the default mode is being turned off (i.e. we are exiting the
    % mode, do not revert to the default mode.
    hMode = getuimode(hThis,hThis.DefaultUIMode);
    if ~isempty(hMode) && strcmpi(hMode.Name,currMode.Name)
        hMode = [];
    end
end


if ~isempty(currMode)
    if ~currMode.Blocking
        set(currMode,'Enable','off');
        hThis.Blocking = false;
    else
        error(message('MATLAB:modes:modemanager:CannotInterrupt'));
    end
end

hThis.CurrentMode = hMode;
if ~isempty(hMode)
    set(hMode,'Enable','on');
    hThis.Blocking = hMode.Blocking;
else
    hThis.Blocking = false;
end

