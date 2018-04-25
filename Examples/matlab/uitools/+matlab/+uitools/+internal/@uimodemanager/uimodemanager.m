classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) uimodemanager < hgsetget 
    % This function is undocumented and will change in a future release

%matlab.uitools.internal.uimodemanager class
%    uitools.uimodemanager properties:
%       CurrentMode  
%       DefaultUIMode 
%       Blocking   
%
%    uitools.uimodemanager methods:
%       clearModes -  Delete all registered modes for the figure.
%       getMode -  Given the name of a mode, return the mode object, providing it has been
%       registerMode -  Create a new mode and register it with the mode manager.
%       unregisterMode -  Given a mode, remove it from the list of modes currently
% Copyright 2013-2014 The MathWorks, Inc.

properties (Transient, SetObservable, GetObservable)
    CurrentMode = '';
end

properties
    % A default mode may be specified. Setting this property
    % has the side-effect of starting the default mode if no
    % mode has already been activated in the figure.
    DefaultUIMode = '';
    Blocking = false;
end

properties (SetAccess=protected, Transient, Hidden)
    FigureHandle = [];
    WindowListenerHandles = [];
    WindowMotionListenerHandles = [];
    DeleteListener = [];
end

properties (Transient, Hidden)
    PreviousWindowState = [];    
end

properties (Access=protected, Transient, Hidden)
    RegisteredModes = [];
end

methods  % constructor block
    function [hThis] = uimodemanager(hFig)
    % Constructor for the mode
    % Syntax: matlab.uitools.internal.uimodemanager(figure)
    if ~ishghandle(hFig,'figure')
        error(message('MATLAB:uimodes:modemanager:InvalidConstructor'));
    end
    
    % There can only be one mode manager per figure
    if ~isprop(hFig,'ModeManager')
            p = addprop(hFig,'ModeManager');
            p.Hidden = true;
            p.Transient = true;
    end
    mmgr = get(hFig,'ModeManager');
    if isempty(mmgr) || ~isvalid(mmgr) %((~isobject(mmgr) || ~isvalid(mmgr)) && ~ishandle(mmgr))
        hThis.FigureHandle = hFig;
        
        hThis.DeleteListener = matlab.ui.internal.createListener(hFig,'ObjectBeingDestroyed',@(obj,evd)(localDelete(hThis)));
        if isprop(hFig,'ScribeClearModeCallback')
            s = hFig.ScribeClearModeCallback;
        else
            s = [];
        end
        %To prevent odd behavior when copying, make sure the scribe callback
        %doesn't refer to a different figure:
        if ~isempty(s) && isequal(s{1},@set)
            if isa(handle(s{2}),'uitools.uimodemanager') && ~isequal(s{2}.FigureHandle, hFig)
                if isprop(hFig,'ScribeClearModeCallback')
                    hFig.ScribeClearModeCallback = [];
                end
            end
        end
        % Define listeners for window state
        window_prop = [findprop(hFig,'WindowButtonDownFcn'),...
            findprop(hFig,'WindowButtonUpFcn'),...
            findprop(hFig,'WindowScrollWheelFcn'),...
            findprop(hFig,'WindowKeyPressFcn'),...
            findprop(hFig,'WindowKeyReleaseFcn'),...
            findprop(hFig,'KeyPressFcn'),...
            findprop(hFig,'KeyReleaseFcn')];
        
        l = matlab.ui.internal.createListener(hFig,window_prop,'PreSet',@(obj,evd)(localModeWarn(obj,evd,hThis)));
        l(end+1) = matlab.ui.internal.createListener(hFig,window_prop,'PostSet',@(obj,evd)(localModeRestore(obj,evd,l(end),hThis)));
    
        matlab.graphics.internal.setListenerState(l,'off');
        hThis.WindowListenerHandles = l;
        
        l = matlab.ui.internal.createListener(hFig,findprop(hFig,'WindowButtonMotionFcn'),'PreSet',@(obj,evd)(localModeWarn(obj,evd,hThis)));
        l(end+1) = matlab.ui.internal.createListener(hFig,findprop(hFig,'WindowButtonMotionFcn'),'PostSet',@(obj,evd)(localModeRestore(obj,evd,l(end),hThis)));
        
        matlab.graphics.internal.setListenerState(l,'off');
        hThis.WindowMotionListenerHandles = l;
        
        set(hFig,'ModeManager',hThis);
    else
        error(message('MATLAB:uimodes:modemanager:ExistingManager'));
    end
    end  % uimodemanager
    
    
    %------------------------------------------------------------------------%

end  % constructor block

methods 
    function set.CurrentMode(obj,value)
        obj.CurrentMode = localSetMode(obj,value);
    end

    function set.DefaultUIMode(obj,value)
        validateattributes(value,{'char'}, {'row'},'','DefaultUIMode')
        obj.DefaultUIMode = localSetDefault(obj,value);
    end

end   % set and get functions 

methods  %% public methods
    clearModes(hThis)
    regMode = getMode(hThis,name)
    hMode = registerMode(hThis,hMode)
    unregisterMode(hThis,hMode)
end  %% public methods 

end  % classdef

function newDefault = localSetDefault(hThis, valueProposed)
% Set the default mode for the figure. This will have the side-effect
% of activating the mode if there is no mode currently active.

newDefault = valueProposed;
% If the value is empty, return and take no further action.
if isempty(newDefault)
    return;
end

% Validate that the mode has already been registered with the figure:
actMode = getuimode(hThis.FigureHandle, newDefault);
if isempty(actMode)
    error(message('MATLAB:modes:modemanager:UnregisteredMode'));
end

% If there is already a mode active, return and take no further action.
if ~isempty(hThis.CurrentMode)
    return;
end

% Turn on the default mode.
set(hThis,'CurrentMode',actMode);
end  % localSetDefault


%------------------------------------------------------------------------%
function newMode = localSetMode(hThis, valueProposed)
% Register a mode with the mode manager, disabling any active mode and
% enabling the new mode.

%if ~isa(valueProposed,'uitools.uimode') && ~isempty(valueProposed)
if ~isempty(valueProposed) && ~isa(valueProposed,'matlab.uitools.internal.uimode')
    error(message('MATLAB:modes:modemanager:InvalidMode'));
end
currMode = get(hThis,'CurrentMode');
if ~isempty(currMode) && isvalid(currMode) %ishandle(currMode)
    if ~currMode.Blocking
        %Disable listeners
        matlab.graphics.internal.setListenerState(hThis.WindowListenerHandles,'off');
        if currMode.WindowButtonMotionFcnInterrupt
            matlab.graphics.internal.setListenerState(hThis.WindowMotionListenerHandles,'off');
        end        
        set(currMode,'Enable','off');
        hThis.Blocking = false;
    else
        error(message('MATLAB:modes:modemanager:CannotInterrupt'));
    end
end

newMode = valueProposed;

if ~isempty(newMode)
    %Register with scribe callbacks to maintain consistency:
    localScribeclearmode(hThis);
    set(newMode,'Enable','on');
    %Enable listeners
    matlab.graphics.internal.setListenerState(hThis.WindowListenerHandles,'on');
    if newMode.WindowButtonMotionFcnInterrupt
        matlab.graphics.internal.setListenerState(hThis.WindowMotionListenerHandles,'on');
    end
    hThis.Blocking = newMode.Blocking;
end
end  % localSetMode


%----------------------------------------------------------------------%
function localScribeclearmode(hThis)
%Register off function, if necessary
fig = hThis.FigureHandle;
s = [];
if isprop(fig,'ScribeClearModeCallback')
    s = fig.ScribeClearModeCallback;
end
if isempty(s) || ~isequal(s{1},@set)
    scribeclearmode(fig,@set,hThis,'CurrentMode','');
end
end  % localScribeclearmode

function localModeWarn(hProp,evd,hThis)
    hThis.PreviousWindowState = get(evd.AffectedObject,hProp.Name);
    warning(message('MATLAB:modes:mode:InvalidPropertySet', hProp.Name));
end  % localModeWarn


%------------------------------------------------------------------------%
function localModeRestore(hProp,evd,listener,hThis)
    matlab.graphics.internal.setListenerState(listener,'off');
    set(evd.AffectedObject,hProp.Name,hThis.PreviousWindowState);
    matlab.graphics.internal.setListenerState(listener,'on');
end  % localModeRestore


%------------------------------------------------------------------------%
function localDelete(hThis)
    if isvalid(hThis)
        delete(hThis);
    end
end  % localDelete

