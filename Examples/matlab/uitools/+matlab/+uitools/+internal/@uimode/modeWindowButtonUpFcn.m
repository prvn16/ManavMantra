function modeWindowButtonUpFcn(~,hFig,evd,hThis,newButtonUpFcn)
% This function is undocumented and will change in a future release

% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2013-2017 The MathWorks, Inc.

appdata = hThis.FigureState;

%Check for multiple buttons down
appdata.numButtonsDown = appdata.numButtonsDown - 1;
appdata.numButtonsDown = max(appdata.numButtonsDown,0);
hThis.FigureState = appdata;
if appdata.numButtonsDown ~= 0
    return;
end

appdata = hThis.FigureState;
if isempty(appdata) 
    % Guard against the FigureState property being empty. This should 
    % never happen while the mode is active, but is was reported in
    % g841381.
    return
end

%Restore any button functions on the object we clicked on
if isfield(appdata, 'ButtonDownFcnRestorer')
    delete(appdata.ButtonDownFcnRestorer);
    appdata.ButtonDownFcnRestorer = [];
end
hThis.FigureState = appdata;

% If the mode had filtered the button down and we have a button-up function
% that must be fired, call it instead of the mode's callback.
hM = uigetmodemanager(hFig);

if ~isempty(hThis.UserButtonUpFcn)
    hFig = hThis.FigureHandle;
    try
        hgfeval(hThis.UserButtonUpFcn,double(hFig),[])
    catch
        warning(message('MATLAB:uitools:uimode:callbackerror'));
    end
    hThis.UserButtonUpFcn = '';
    return;
end
matlab.graphics.internal.setListenerState(hThis.WindowListenerHandles,'off');
matlab.graphics.internal.setListenerState(hM.WindowListenerHandles,'on');

% Execute the specified callback function
hgfeval(newButtonUpFcn,hFig,evd);

% Deal with the context menu. Depending on the platform, the context-menu
% may be attached to the object that the mouse is over, or the object that
% was initially clicked. We will handle both cases.
if appdata.doContext
    obj = evd.HitObject;
    if isfield(appdata,'CurrentObj') && ~isequal(obj,appdata.CurrentObj.Handle) && isprop(obj,'UIContextMenu') ...
        && ~(ishghandle(obj,'uicontrol') || ishghandle(obj,'uitable'))
        
        CMToRestore = obj.UIContextMenu;
        appdata.ReleaseContextMenuRestorer = onCleanup(@() setCMIfValid(obj, 'UIContextMenu', CMToRestore));
        obj.UIContextMenu = hThis.UIContextMenu;
        hThis.FigureState = appdata;
    end
end

% If the mode (or one of its ancestors) is a one-shot mode, exit the mode:
hMode = hThis;
while ~isempty(hMode)
    if hMode.IsOneShot
        hParentMode = hMode.ParentMode;
        if isempty(hParentMode)
            activateuimode(hThis.FigureHandle,'');
        else
            if isequal(hParentMode.CurrentMode,hMode)
                activateuimode(hParentMode,'');
            end
        end
    end
    hMode = hMode.ParentMode;
end



function setCMIfValid(h, prop, value)
% Reset the context menu if both the object handle and uicontextmenu
% handle are valid
if isvalid(h) && (isempty(value) || isvalid(value))
    h.(prop) = value;
end
