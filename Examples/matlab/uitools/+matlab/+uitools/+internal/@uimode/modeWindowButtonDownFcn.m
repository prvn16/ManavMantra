
function modeWindowButtonDownFcn(~,hFig,evd,hThis,newButtonDownFcn)
% This function is undocumented and will change in a future release

% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2013-2017 The MathWorks, Inc.

% If we are in a bad state due to figure-copying, 
% or an invalid figure, try to recover gracefully:
if ~isvalid(hThis) || hFig ~= hThis.FigureHandle
    if ishghandle(hFig)
        set(hFig,'WindowButtonDownFcn','');
        set(hFig,'WindowButtonUpFcn','');
        set(hFig,'WindowKeyPressFcn','');
        set(hFig,'WindowKeyReleaseFcn','');
        set(hFig,'KeyPressFcn','');
        set(hFig,'KeyReleaseFcn','');
        set(hFig,'Pointer',get(0,'DefaultFigurePointer'));
        if isprop(hFig,'ScribeClearModeCallback')
            hFig.ScribeClearModeCallback = '';  
        end    
    end
    return;
end

appdata = hThis.FigureState;
if isempty(appdata) 
    % Guard against the FigureState property being empty. This should 
    % never happen while the mode is active, but is was reported in
    % g841381.
    return
end

appdata.numButtonsDown = appdata.numButtonsDown+1;
sel_type = get(hFig,'selectiontype');

% Maintain the number of keys down
if (appdata.numButtonsDown ~= 1)
    if strcmpi(sel_type,'extend')
        hThis.FigureState = appdata;
        return;
    else
        %We are in a bad state. Reset the number of buttons down before we
        %get into trouble
        appdata.numButtonsDown = 1;
    end
end

% Restore the context menus of any previously clicked objects
if isfield(appdata,'ClickContextMenuRestorer') && ~isempty(appdata.ClickContextMenuRestorer)
    delete(appdata.ClickContextMenuRestorer);
    appdata.ClickContextMenuRestorer = [];
end
if isfield(appdata,'ReleaseContextMenuRestorer') && ~isempty(appdata.ReleaseContextMenuRestorer)
    delete(appdata.ReleaseContextMenuRestorer);
    appdata.ReleaseContextMenuRestorer = [];
end

% Restore the ButtonDownFcn if it hasn't already been done
if isfield(appdata,'ButtonDownFcnRestorer') && ~isempty(appdata.ButtonDownFcnRestorer)
    delete(appdata.ButtonDownFcnRestorer);
    appdata.ButtonDownFcnRestorer = [];
end

h = evd.HitObject;
appdata.CurrentObj.Handle = h;

% Find axes that was clicked on (could be 0, 1 or multiple)
appdata.CurrentAxes = matlab.graphics.interaction.internal.hitAxes(hFig, evd);

%If we clicked on a UIControl or UITable object, return unless we are 
%suspending the callback.
if ~isempty(h) && (ishghandle(h,'uicontrol') || ishghandle(h,'uitable'))
    if ~hThis.UIControlInterrupt
        return;
    end
end

% If the mode contains an object whose callback needs to fire, return
if ~isempty(hThis.ButtonDownFilter)
    blockState = hThis.Blocking;
    hThis.Blocking = true;   
    try
        if hgfeval(hThis.ButtonDownFilter,h,[])
            hThis.Blocking = blockState;
            % It is possible that a button-down function would want to install its
            % own button up. To reduce command-window warnings and facilitate this,
            % we will temporarily turn off the mode manager's listeners and install
            % our own. With the exception of WindowButtonUpFcn, they will all be
            % no-ops.
            hM = uigetmodemanager(hThis.FigureHandle);
            matlab.graphics.internal.setListenerState(hM.WindowListenerHandles,'off');
            matlab.graphics.internal.setListenerState(hThis.WindowListenerHandles,'on');
            return;
        end
    catch %#ok<CTCH>
        warning(message('MATLAB:uitools:uimode:callbackerror'));
    end
    hThis.Blocking = blockState;
end

hasButtonDownFcn = ~isempty(h) && isprop(h,'ButtonDownFcn') && ~isequal(get(h,'ButtonDownFcn'),'');
legendWithAutoButtonDownFcn = matlab.graphics.interaction.internal.hitLegendWithDefaultButtonDownFcn(evd);
% Disable any button functions on the object we clicked on 
if hasButtonDownFcn && ~legendWithAutoButtonDownFcn
    FcnToRestore = h.ButtonDownFcn;
    appdata.ButtonDownFcnRestorer = onCleanup(@() setIfValid(h, 'ButtonDownFcn', FcnToRestore));
    set(h,'ButtonDownFcn','');
end

% Cache the original context menu of the object. There could be situations
% where the context menu of the object can be altered by a mode. make sure
% to cache it and restore before executing the mode callback.
appdata.doContext = false;
if ~isempty(h) && isprop(h,'UIContextMenu')
    CMToRestore = h.UIContextMenu;
    appdata.ClickContextMenuRestorer = onCleanup(@() setCMIfValid(h, 'UIContextMenu', CMToRestore));   
end

%Execute the specified callback function
hgfeval(newButtonDownFcn,hFig,evd);

%If we clicked on a Chart
hitChart = ~isempty(ancestor(h,'matlab.graphics.chart.Chart'));

%Deal with the context menu
if ~isempty(h) && strcmpi(sel_type,'alt') && isprop(h,'UIContextMenu')
    % If we right-clicked on a legend where the ButtonDownFcn hasn't been
    % set or a chart, or the mode doesn't want to use it's contextmenu,
    % then skip replacing the hit object's contextmenu
    if ~legendWithAutoButtonDownFcn && ~hitChart && strcmp(hThis.UseContextMenu,'on')
        if hThis.ShowContextMenu && ~isempty(hThis.UIContextMenu)     
            set(h,'UIContextMenu',hThis.UIContextMenu);
        else
            set(h,'UIContextMenu',[]);
        end
        appdata.doContext = true;
    end
    hThis.ShowContextMenu = true;
end

hThis.FigureState = appdata;

function setIfValid(h, prop, value)
% Reset a property if both the object handle is still valid
if isvalid(h)
    h.(prop) = value;
end

function setCMIfValid(h, prop, value)
% Reset the context menu if both the object handle and uicontextmenu
% handle are valid
if isempty(value) || isvalid(value)
    setIfValid(h, prop, value)
end
