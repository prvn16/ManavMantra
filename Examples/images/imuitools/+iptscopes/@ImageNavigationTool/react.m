function react(this)
%REACT    React to current zoom state

%   Copyright 2007-2017 The MathWorks, Inc.

% Set toggle button states and menu checks appropriately
% Install 'zoom' functionality in figure

% Install cursor and functions
hSP  = this.ScrollPanel;
hVV  = this.Application.Visual;
hmgr = getGUI(this.Application);
if ~ishghandle(hSP) || strcmp(this.AppliedMode, this.Mode)
    return;
end
this.AppliedMode = this.Mode;
spAPI = iptgetapi(hSP);

hFig  = this.Application.Parent;
hAxes = hVV.Axes;

% Turn off warning for using imuitoolsgate
warnState = warning('off','images:imuitoolsgate:undocumentedFunction');

if isempty(hmgr)
    set(this.ZoomInMenu,   'Checked', 'Off');
    set(this.ZoomOutMenu,  'Checked', 'Off');
    set(this.PanMenu,      'Checked', 'Off');
    set(this.MaintainMenu, 'Checked', 'Off');
    
    set(this.ZoomInButton,   'State', 'Off');
    set(this.ZoomOutButton,  'State', 'Off');
    set(this.PanButton,      'State', 'Off');
    set(this.MaintainButton, 'State', 'Off');
else
    hZoomIn  = hmgr.findchild('Base/Menus/Tools/Zoom/PanZoom/ZoomIn');
    hZoomOut = hmgr.findchild('Base/Menus/Tools/Zoom/PanZoom/ZoomOut');
    hPan     = hmgr.findchild('Base/Menus/Tools/Zoom/PanZoom/Pan');
    hFit     = hmgr.findchild('Base/Menus/Tools/Zoom/Mag/Maintain');
    
    set(get(hZoomIn,  'WidgetHandle'), 'Checked', 'Off');
    set(get(hZoomOut, 'WidgetHandle'), 'Checked', 'Off');
    set(get(hPan,     'WidgetHandle'), 'Checked', 'Off');
    set(get(hFit,     'WidgetHandle'), 'Checked', 'Off');
end

enab = 'On';
fun  = [];  % no operation
ptr  = setptr('arrow');

switch lower(this.Mode)
    case 'zoomin'
        % zoom-in mode
        fun = imuitoolsgate('FunctionHandle','imzoomin');
        ptr = setptr('glassplus');
        
        if isempty(hmgr)
            set(this.ZoomInMenu, 'Checked', 'On');
            set(this.ZoomInButton, 'State', 'On');
        else
            set(get(hZoomIn, 'WidgetHandle'), 'Checked', 'On');
        end
        
    case 'zoomout'
        % zoom-out mode
        fun = imuitoolsgate('FunctionHandle','imzoomout');
        ptr = setptr('glassminus');
        
        if isempty(hmgr)
            set(this.ZoomOutMenu, 'Checked', 'On');
            set(this.ZoomOutButton, 'State', 'On');
        else
            set(get(hZoomOut, 'WidgetHandle'), 'Checked', 'On');
        end
        
    case 'pan'
        % Panning mode.
        fun = imuitoolsgate('FunctionHandle','impan');
        ptr = setptr('hand');
        
        if isempty(hmgr)
            set(this.PanMenu, 'Checked', 'On');
            set(this.PanButton, 'State', 'On');
        else
            set(get(hPan, 'WidgetHandle'), 'Checked', 'On');
        end
        
    case 'fittoview'
        
        enab = 'off';
        
        % Fit to view.
        if isempty(hmgr)
            set(this.MaintainMenu, 'Checked', 'On');
            set(this.MaintainButton, 'State', 'On');
        else
            setWidgetProperty(hFit, 'Checked', 'On');
        end
        
        % Set the magnification of the scroll panel to be the "fitmag"
        spAPI.setMagnification(spAPI.findFitMag());
end

% Set the enable state of the widgets based on the
if isempty(hmgr)
    set([this.ZoomInMenu this.ZoomOutMenu this.PanMenu], 'Enable', enab);
    set([this.ZoomInButton this.ZoomOutButton this.PanButton], 'Enable', enab);
else
    set([hZoomIn hZoomOut hPan], 'Enable', enab);
end
if images.internal.isFigureAvailable()
    if isempty(this.Application.DataSource) || isDataEmpty(this.Application.DataSource)
        enab = 'off';
    end
    if isempty(hmgr)
        set(this.MagCombobox, 'Enable', enab);
    else
        set(hmgr.findchild('Base/Toolbars/Main/Tools/Zoom/Mag/MagCombo'), 'Enable', enab);
    end
end

% Setup the pointer manager.
if isempty(fun)
    % If there is no zoom function, clear pointer behavior from the axes.
    iptSetPointerBehavior(hAxes,[]);
else
    % If there is a navigation mode, set the axes' pointer behavior.
    iptSetPointerBehavior(hAxes, @(hFig, currentPoint) set(hFig, ptr{:}));
    iptPointerManager(hFig, 'enable');
end

% Install new zoom function.
spAPI.setImageButtonDownFcn(fun)

warning(warnState);

end