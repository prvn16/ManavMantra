function newValue = setCallbackFcn(hThis, valueProposed, propToChange)
% This function is undocumented and will change in a future release

% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are inserted here.

%   Copyright 2013 The MathWorks, Inc.

newValue = valueProposed;
%If the mode is on, this change should be reflected in the figure
%callbacks
if strcmp(hThis.Enable,'on')
    %Disable listeners
    mmgr = uigetmodemanager(hThis.FigureHandle);
    enableState = mmgr.WindowListenerHandles(1).Enabled;
    if (ischar(enableState) && strcmpi(enableState,'on')) || ...
            (islogical(enableState) && enableState)
        mmgrEnableFunction = @(hL)matlab.graphics.internal.setListenerState(hL,'on');
    else
        mmgrEnableFunction = @(hL)matlab.graphics.internal.setListenerState(hL,'off');
    end
    matlab.graphics.internal.setListenerState(mmgr.WindowListenerHandles,'off');
    windowListEnableState = hThis.WindowListenerHandles(1).Enabled;
    if (ischar(windowListEnableState) && strcmpi(windowListEnableState,'on')) || ...
            (islogical(windowListEnableState) && windowListEnableState)
        windowListEnableFunction = @(hL)matlab.graphics.internal.setListenerState(hL,'on');
    else
        windowListEnableFunction = @(hL)matlab.graphics.internal.setListenerState(hL,'off');
    end
    matlab.graphics.internal.setListenerState(hThis.WindowListenerHandles,'off');
    switch propToChange
        case 'WindowButtonDownFcn'
            set(hThis.FigureHandle,propToChange,{@localModeWindowButtonDownFcn,hThis,newValue});
        case 'WindowButtonUpFcn'
            set(hThis.FigureHandle,propToChange,{@localModeWindowButtonUpFcn,hThis,newValue});
        case 'WindowKeyPressFcn'
            set(hThis.FigureHandle,propToChange,{@localModeWindowKeyPressFcn,hThis,newValue});
        case 'WindowKeyReleaseFcn'
            set(hThis.FigureHandle,propToChange,{@localModeWindowKeyReleaseFcn,hThis,newValue});           
        otherwise
            set(hThis.FigureHandle,propToChange,newValue);
    end
    %Enable listeners
    mmgrEnableFunction(mmgr.WindowListenerHandles);
    windowListEnableFunction(hThis.WindowListenerHandles);
end

%------------------------------------------------------------------------%
function localModeWindowButtonDownFcn(hFig,evd,hThis,newButtonDownFcn)

hThis.modeWindowButtonDownFcn(hFig,evd,hThis,newButtonDownFcn);

%------------------------------------------------------------------------%
function localModeWindowButtonUpFcn(hFig,evd,hThis,newButtonUpFcn)

hThis.modeWindowButtonUpFcn(hFig,evd,hThis,newButtonUpFcn);

%------------------------------------------------------------------------%
function localModeWindowKeyPressFcn(hFig,evd,hThis,newButtonDownFcn)

hThis.modeWindowKeyPressFcn(hFig,evd,hThis,newButtonDownFcn);

%------------------------------------------------------------------------%
function localModeWindowKeyReleaseFcn(hFig,evd,hThis,newButtonUpFcn)

hThis.modeWindowKeyReleaseFcn(hFig,evd,hThis,newButtonUpFcn);
