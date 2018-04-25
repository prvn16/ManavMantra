function ret=cameratoolbar(varargin)
%CAMERATOOLBAR  Interactively manipulate camera.
%   CAMERATOOLBAR creates a new toolbar that enables interactive
%   manipulation of a scene's camera and light by dragging the
%   mouse on the figure window; the camera properties of the
%   current axes (gca) are affected. Several camera properties
%   are set when the toolbar is initialized.
%
%   CAMERATOOLBAR('NoReset') creates the toolbar without setting
%   any camera properties.
%
%   CAMERATOOLBAR('SetMode' mode) sets the mode of the
%   toolbar. Mode can be: 'orbit', 'orbitscenelight', 'pan',
%   'dollyhv', 'dollyfb', 'zoom', 'roll', 'nomode'.
%
%   CAMERATOOLBAR('SetCoordSys' coordsys) sets the principal axis
%   of the camera motion. coordsys can be: 'x', 'y', 'z', 'none'.
%
%   CAMERATOOLBAR('Show') shows the toolbar.
%   CAMERATOOLBAR('Hide') hides the toolbar.
%   CAMERATOOLBAR('Toggle') toggles the visibility of the toolbar.
%
%   CAMERATOOLBAR('ResetCameraAndSceneLight') resets the current
%   camera and scenelight.
%   CAMERATOOLBAR('ResetCamera') resets the current camera.
%   CAMERATOOLBAR('ResetSceneLight') resets the current scenelight.
%   CAMERATOOLBAR('ResetTarget') resets the current camera target.
%
%   MODE = CAMERATOOLBAR('GetMode') returns the current mode.
%   PAXIS = CAMERATOOLBAR('GetCoordSys') returns the current
%   principal axis.
%   VIS = CAMERATOOLBAR('GetVisible') returns the visibility.
%   H = CAMERATOOLBAR returns the handle to the toolbar.
%
%   CAMERATOOLBAR('Close') removes the toolbar.
%
%   CAMERATOOLBAR(FIG,...) specify figure handle as first argument.
%
%   Note: Rendering performance is affected by presence of OpenGL
%   hardware.
%
%   See also ROTATE3D, ZOOM, PAN.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin>0 && isscalar(varargin{1}) && ishghandle(varargin{1},'figure')
    [hfig,haxes] = currenthandles(varargin{1});
    vargin = varargin(2:end);
    nin = nargin-1;
else
    [hfig,haxes] = currenthandles; % use gcf/gcbf
    vargin = varargin;
    nin = nargin;
end

manager = getCameraToolbarManager(hfig);

if nin==0
    if ~isempty(haxes)
        axis(haxes,'vis3d')
    end
    show(hfig);
    setmode(manager, hfig, 'orbit');
    arg = '';
else
    arg = lower(vargin{1});
    if ~strcmp(arg, 'init') && ~strcmp(arg, 'motion') && ...
            (length(arg)<3 || any(arg(1:3)~='get'))
        init(hfig);
    end
end

% Prepare toolbar handle as default return value
r = manager.mainToolbarHandle;

switch arg
    % documented input strings
    case 'noreset'
        show(hfig);
    case 'setmode'
        newmode = vargin{2};
        setmode(manager, hfig, newmode);
    case 'setcoordsys'
        coordsys = vargin{2};
        setcoordsys(manager, hfig, coordsys);
    case 'show'
        show(hfig);
    case 'hide'
        set(manager.mainToolbarHandle, 'Visible', 'off');
    case 'toggle'
        h = manager.mainToolbarHandle;
        newval = strcmp(get(h, 'Visible'), 'off');
        set(h, 'Visible', bool2OnOff(manager, newval))
    case 'resetcameraandscenelight'
        resetcameraandscenelight(manager, hfig);
    case 'resetcamera'
        if ~isempty(haxes)
            resetCameraProps(manager,haxes);
        end
    case 'resetscenelight'
        resetScenelightIfValid(manager,hfig);
    case 'resettarget'
        resettarget(manager,hfig);        
    case 'getmode'
        r = getmode(manager);
    case 'getcoordsys'
        r = getcoordsys(manager);        
    case 'getvisible'
        h = manager.mainToolbarHandle;
        r = strcmp(get(h, 'Visible'), 'on');
    case 'close'
        close(hfig);
        r = [];        
        
    % Undocumented inputs
    case 'down'
        evd = varargin{3};
        down_callback(manager, hfig, evd, true);
    case 'stopmoving'
        stopmoving(manager);
    case 'updatetoolbar'
        updateToolbar(manager, hfig)   
    case 'togglescenelight'
        togglescenelight(manager, hfig);
    case 'setprojection'
        proj = vargin{2};
        setprojection(manager, hfig, proj);
    case 'resetall'
        h = [manager.scenelights.h]; delete(h(ishghandle(h)));
        updateToolbar(manager, hfig)
        resetcameraandscenelight(manager, hfig);
    case 'nomode'
        nomode(hfig);
    case 'init'
        r = init(hfig);
    case 'save'
        if ~isempty(manager.wcb)
            restoreWindowCallbacks(manager,hfig);
            restoreWindowCursor(manager,hfig);
        end
        stopmoving(manager);
        delete(manager.mainToolbarHandle);
        r = [];
    case ''

    otherwise
        error(message('MATLAB:cameratoolbar:unrecognizedinput'));
end

if nargout>0
    ret = r;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function manager = getCameraToolbarManager(hfig)

if isprop(hfig, 'CameraToolbarManager')
    if isvalid(hfig.CameraToolbarManager)
        manager = hfig.CameraToolbarManager;
    else
        hfig.CameraToolbarManager = matlab.graphics.internal.CameraToolBarManager;
        manager = hfig.CameraToolbarManager;
    end
else
    p = addprop(hfig, 'CameraToolbarManager');
    p.Transient = true;
    p.Hidden = true;
    hfig.CameraToolbarManager = matlab.graphics.internal.CameraToolBarManager;
    manager = hfig.CameraToolbarManager;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hfig,haxes]=currenthandles(hfig)
% Obtaining the correct handle to the current figure and axes in all cases:
% handlevisibility ON-gcbf; OFF-gcbf/gcf.

if nargin<1
    if ~isempty(gcbf)
        hfig=gcbf;
    else
        % Get the CurrentFigure even if HandleVisibility is not on
        cacheShowHiddenHandles = get(groot,'ShowHiddenHandles');
        set(groot,'ShowHiddenHandles', 'on'); 
        hfig = get(groot,'CurrentFigure');
        set(groot,'ShowHiddenHandles',cacheShowHiddenHandles);
        if isempty(hfig)
            hfig = gcf;
        end
    end
end

haxes = hfig.CurrentAxes;
if ~matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
    haxes = [];
end

function close(hfig)
manager = getCameraToolbarManager(hfig);
hManager = uigetmodemanager(hfig);
oldMode = hManager.CurrentMode;
%disable ui modes so we can adjust callbacks without warnings
activateuimode(hfig,'');
if ~isempty(manager.wcb)
    restoreWindowCallbacks(manager, hfig);
    restoreWindowCursor(manager, hfig);
end
stopmoving(manager);
delete(manager);
%restore previous ui mode
set(hManager, 'CurrentMode',oldMode);

function r = getmode(manager)
if isempty(manager)
    r = '';
else
    r = manager.mode;
end
        
function r = getcoordsys(manager)
if isempty(manager)
    r = 'z';
else
    r = manager.coordsys;
end
        
function show(hfig)
manager = getCameraToolbarManager(hfig);
if isempty(manager.mainToolbarHandle) || ~isvalid(manager.mainToolbarHandle)
    init(hfig);
end
set(manager.mainToolbarHandle, 'Visible', 'on');
        
function r = init(hfig)
manager = getCameraToolbarManager(hfig);
r = [];
ctb = findall(hfig, 'Tag', 'CameraToolBar');
if isempty(ctb) || ~isvalid(ctb)
    r = createToolbar(manager, hfig);
end

updateToolbar(manager, hfig)
        

