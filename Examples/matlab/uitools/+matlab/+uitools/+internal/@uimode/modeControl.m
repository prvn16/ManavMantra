function newValue = modeControl(hThis,valueProposed)
% This function is undocumented and will change in a future release

%Prepare and restore the mode state.

%   Copyright 2013-2017 The MathWorks, Inc.

newValue = valueProposed;

hManager = uigetmodemanager(hThis.FigureHandle);
%Disable listeners on the mode manager:
matlab.graphics.internal.setListenerState(hManager.WindowListenerHandles,'off');

if strcmp(valueProposed,'on')
    localPrepareFigure(hThis);
    hgfeval(hThis.ModeStartFcn);
    localStartMode(hThis);
else
    localEndMode(hThis);
    %Disable listeners on the mode manager:
    matlab.graphics.internal.setListenerState(hManager.WindowListenerHandles,'off');
    hgfeval(hThis.ModeStopFcn);    
    localRecoverFigure(hThis);
end

%--------------------------------------------------------------------%
function localPrepareFigure(hThis)
hFig = hThis.FigureHandle;

set(hFig,'UIModeEnabled','on');

appdata.WindowButtonDownFcn = get(hFig,'WindowButtonDownFcn');
appdata.WindowButtonUpFcn = get(hFig,'WindowButtonUpFcn');
appdata.WindowScrollWheelFcn = get(hFig,'WindowScrollWheelFcn');
appdata.WindowKeyPressFcn = get(hFig,'WindowKeyPressFcn');
appdata.WindowKeyReleaseFcn = get(hFig,'WindowKeyReleaseFcn');
appdata.Pointer = get(hFig,'Pointer');
appdata.PointerShapeCData = get(hFig,'PointerShapeCData');
appdata.PointerShapeHotSpot = get(hFig,'PointerShapeHotSpot');
appdata.KeyPressFcn = get(hFig,'KeyPressFcn');
appdata.KeyReleaseFcn = get(hFig,'KeyReleaseFcn');
if hThis.WindowButtonMotionFcnInterrupt
    appdata.WindowButtonMotionFcn = get(hFig,'WindowButtonMotionFcn');
    set(hFig,'WindowButtonMotionFcn','');
end
appdata.doContext = false;
appdata.numButtonsDown = 0;
hThis.FigureState = appdata;

%--------------------------------------------------------------------%
function localRecoverFigure(hThis)
hFig = hThis.FigureHandle;
appdata = hThis.FigureState;

% If appdata is empty, return early.
if isempty(appdata)
    return;
end

matlab.graphics.internal.setListenerState(hThis.WindowMotionFcnListener,'off');
matlab.graphics.internal.setListenerState(hThis.UIControlSuspendListener,'off');
set(hThis.UIControlSuspendJavaListener,'Enabled','off');

if isempty(hThis.WindowJavaListeners)
    fNames = {};
else
    fNames = fieldnames(hThis.WindowJavaListeners);
end
for i = 1:length(fNames)
    set(hThis.WindowJavaListeners.(fNames{i}),'Enabled','off');
end

hThis.FigureState = [];

if isfield(appdata,'LastObject') && ~isempty(appdata.LastObject) && ...
        ishandle(appdata.LastObject) && ...
        (ishghandle(appdata.LastObject,'uicontrol') || ishghandle(appdata.LastObject,'uitable'))
    set(appdata.LastObject,'Enable',appdata.UIEnableState);
end

set(hFig,'UIModeEnabled','off');
set(hFig,'WindowButtonDownFcn',appdata.WindowButtonDownFcn);
set(hFig,'WindowButtonUpFcn',appdata.WindowButtonUpFcn);
set(hFig,'WindowScrollWheelFcn',appdata.WindowScrollWheelFcn);
set(hFig,'WindowKeyPressFcn',appdata.WindowKeyPressFcn);
set(hFig,'WindowKeyReleaseFcn',appdata.WindowKeyReleaseFcn);
set(hFig,'Pointer',appdata.Pointer);
set(hFig,'PointerShapeCData',appdata.PointerShapeCData);
set(hFig,'PointerShapeHotSpot',appdata.PointerShapeHotSpot);
set(hFig,'KeyPressFcn',appdata.KeyPressFcn);
set(hFig,'KeyReleaseFcn',appdata.KeyReleaseFcn);
if hThis.WindowButtonMotionFcnInterrupt
    set(hFig,'WindowButtonMotionFcn',appdata.WindowButtonMotionFcn);
end

% When appdata goes out of scope, any restoration functions it holds for
% context menus, KeyPressFcn or ButtonDownFcn will be activated and will
% restore their values

%--------------------------------------------------------------------%
function localStartMode(hThis)
hFig = hThis.FigureHandle;


set(hFig,'WindowButtonUpFcn',{@localModeWindowButtonUpFcn,hThis,hThis.WindowButtonUpFcn});
set(hFig,'WindowButtonDownFcn',{@localModeWindowButtonDownFcn,hThis,hThis.WindowButtonDownFcn});
matlab.graphics.internal.setListenerState(hThis.WindowMotionFcnListener,'on');
set(hFig,'WindowKeyPressFcn',{@localModeWindowKeyPressFcn,hThis,hThis.WindowKeyPressFcn});
set(hFig,'WindowKeyReleaseFcn',{@localModeWindowKeyReleaseFcn,hThis,hThis.WindowKeyReleaseFcn});
set(hFig,'WindowScrollWheelFcn',hThis.WindowScrollWheelFcn);
set(hFig,'KeyPressFcn',{@localModeKeyPressFcn,hThis,hThis.KeyPressFcn});
set(hFig,'KeyReleaseFcn',hThis.KeyReleaseFcn);
if isempty(hThis.WindowJavaListeners)
    fNames = {};
else
    fNames = fieldnames(hThis.WindowJavaListeners);
end
for i = 1:length(fNames)
    set(hThis.WindowJavaListeners.(fNames{i}),'Enabled','on');
end
if hThis.UIControlInterrupt
    matlab.graphics.internal.setListenerState(hThis.UIControlSuspendListener,'on');
    set(hThis.UIControlSuspendJavaListener,'Enabled','on');
end

% Initialize the last object
hThis.FigureState.LastObject = [];
% If the mode has a default mode set, activate it now:
if ~isempty(hThis.DefaultUIMode)
    hThis.BusyActivating = true;
    activateuimode(hThis,hThis.DefaultUIMode);
    hThis.BusyActivating = false;
end

%--------------------------------------------------------------------%
function localEndMode(hThis)
% If the mode has a submode active, stop it before continuing

% Suspend the Window Listeners
matlab.graphics.internal.setListenerState(hThis.WindowListenerHandles,'off');

activateuimode(hThis,hThis.DefaultUIMode);
activateuimode(hThis,'');

if ~isempty(hThis.ModeListenerHandles)
    matlab.graphics.internal.setListenerState(hThis.ModeListenerHandles,'off');
end

%------------------------------------------------------------------------%
function localModeWindowButtonDownFcn(hFig,evd,hThis,newValue)
try
    hThis.modeWindowButtonDownFcn(hFig,evd,hThis,newValue);
catch
end

%------------------------------------------------------------------------%
function localModeWindowButtonUpFcn(hFig,evd,hThis,newValue)
try
    hThis.modeWindowButtonUpFcn(hFig,evd,hThis,newValue);
catch
end

%------------------------------------------------------------------------%
function localModeWindowKeyPressFcn(hFig,evd,hThis,newValue)
try
    hThis.modeWindowKeyPressFcn(hFig,evd,hThis,newValue);
catch
end

%------------------------------------------------------------------------%
function localModeWindowKeyReleaseFcn(hFig,evd,hThis,newValue)
try
    hThis.modeWindowKeyReleaseFcn(hFig,evd,hThis,newValue);
catch
end

%------------------------------------------------------------------------%
function localModeKeyPressFcn(hFig,evd,hThis,newValue)
try
    hThis.modeKeyPressFcn(hFig,evd,hThis,newValue);
catch
end
