function out = zoom(varargin)
%ZOOM   Zoom in and out on a 2-D plot.
%   ZOOM with no arguments toggles the zoom state.
%   ZOOM(FACTOR) zooms the current axis by FACTOR.
%       Note that this does not affect the zoom state.
%   ZOOM ON turns zoom on for the current figure.
%   ZOOM XON or ZOOM YON turns zoom on for the x or y axis only.
%   ZOOM OFF turns zoom off in the current figure.
%
%   ZOOM RESET resets the zoom out point to the current zoom.
%   ZOOM OUT returns the plot to its current zoom out point.
%   If ZOOM RESET has not been called this is the original
%   non-zoomed plot.  Otherwise it is the zoom out point
%   set by ZOOM RESET.
%
%   When zoom is on, click the left mouse button to zoom in on the
%   point under the mouse. Each time you click, the axes limits will be
%   changed by a factor of 2 (in or out).  You can also click and drag
%   to zoom into an area. It is not possible to zoom out beyond the plots'
%   current zoom out point.  If ZOOM RESET has not been called the zoom
%   out point is the original non-zoomed plot.  If ZOOM RESET has been
%   called the zoom out point is the zoom point that existed when it
%   was called. Double clicking zooms out to the current zoom out point -
%   the point at which zoom was first turned on for this figure
%   (or to the point to which the zoom out point was set by ZOOM RESET).
%   Note that turning zoom on, then off does not reset the zoom out point.
%   This may be done explicitly with ZOOM RESET.
%
%   ZOOM(FIG,OPTION) applies the zoom command to the figure specified
%   by FIG. OPTION can be any of the above arguments.
%
%   H = ZOOM(FIG) returns the figure's zoom mode object for customization.
%        The following properties can be modified:
%
%        ButtonDownFilter <function_handle>
%        The application can inhibit the zoom operation under circumstances
%        the programmer defines, depending on what the callback returns. 
%        The input function handle should reference a function with two 
%        implicit arguments (similar to handle callbacks):
%        
%             function [res] = myfunction(obj,event_obj)
%             % OBJ        handle to the object that has been clicked on.
%             % EVENT_OBJ  handle to event object (empty in this release).
%             % RES        a logical flag to determine whether the zoom
%                          operation should take place or the 
%                          'ButtonDownFcn' property of the object should 
%                          take precedence.
%
%        ActionPreCallback <function_handle>
%        Set this callback to listen to when a zoom operation will start.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object.
%
%             The event object has the following read only 
%             property:
%             Axes             The handle of the axes that is being zoomed.
%
%        ActionPostCallback <function_handle>
%        Set this callback to listen to when a zoom operation has finished.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object. The object has the same
%                          properties as the EVENT_OBJ of the
%                          'ModePreCallback' callback.
%
%        Enable  'on'|{'off'}
%        Specifies whether this figure mode is currently 
%        enabled on the figure.
%
%        FigureHandle <handle>
%        The associated figure handle. This property supports GET only.
%
%        Motion 'horizontal'|'vertical'|{'both'}
%        The type of zooming for the figure.
%
%        Direction {'in'}|'out'
%        The direction of the zoom operation.
%
%        RightClickAction 'InverseZoom'|{'PostContextMenu'}
%        The behavior of a right-click action. A value of 'InverseZoom' 
%        will cause a right-click to zoom out. A value of 'PostContextMenu'
%        will display a context menu. This setting will persist between 
%        MATLAB sessions.
%
%        UIContextMenu <handle>
%        Specifies a custom context menu to be displayed during a
%        right-click action. This property is ignored if the
%        'RightClickAction' property has been set to 'InverseZoom'.
%
%   FLAGS = isAllowAxesZoom(H,AXES)
%       Calling the function ISALLOWAXESZOOM on the zoom object, H, with a
%       vector of axes handles, AXES, as input will return a logical array
%       of the same dimension as the axes handle vector which indicate
%       whether a zoom operation is permitted on the axes objects.
%
%   setAllowAxesZoom(H,AXES,FLAG)
%       Calling the function SETALLOWAXESZOOM on the zoom object, H, with
%       a vector of axes handles, AXES, and a logical scalar, FLAG, will
%       either allow or disallow a zoom operation on the axes objects.
%
%   INFO = getAxesZoomMotion(H,AXES)
%       Calling the function GETAXESZOOMMOTION on the zoom object, H, with 
%       a vector of axes handles, AXES, as input will return a character
%       cell array of the same dimension as the axes handle vector which
%       indicates the type of zoom operation for each axes. Possible values
%       for the type of operation are 'horizontal', 'vertical' or 'both'.
%
%   setAxesZoomMotion(H,AXES,STYLE)
%       Calling the function SETAXESZOOMMOTION on the zoom object, H, with a
%       vector of axes handles, AXES, and a character array, STYLE, will
%       set the style of zooming on each axes.
%
%   EXAMPLE 1:
%
%   plot(1:10);
%   zoom on
%   % zoom in on the plot
%
%   EXAMPLE 2:
%
%   plot(1:10);
%   h = zoom;
%   h.Motion = 'horizontal';
%   h.Enable = 'on';
%   % zoom in on the plot in the horizontal direction.
%
%   EXAMPLE 3:
%
%   ax1 = subplot(2,2,1);
%   plot(1:10);
%   h = zoom;
%   ax2 = subplot(2,2,2);
%   plot(rand(3));
%   setAllowAxesZoom(h,ax2,false);
%   ax3 = subplot(2,2,3);
%   plot(peaks);
%   setAxesZoomMotion(h,ax3,'horizontal');
%   ax4 = subplot(2,2,4);
%   contour(peaks);
%   setAxesZoomMotion(h,ax4,'vertical');
%   % zoom in on the plots.
%
%   EXAMPLE 4: (copy into a file)
%       
%   function demo
%   % Allow a line to have its own 'ButtonDownFcn' callback.
%   hLine = plot(rand(1,10));
%   hLine.ButtonDownFcn = 'disp(''This executes'')';
%   hLine.Tag = 'DoNotIgnore';
%   h = zoom;
%   h.ButtonDownFilter = @mycallback;
%   h.Enable = 'on';
%   % mouse click on the line
%
%   function [flag] = mycallback(obj,event_obj)
%   % If the tag of the object is 'DoNotIgnore', then return true.
%   objTag = obj.Tag;
%   if strcmpi(objTag,'DoNotIgnore')
%      flag = true;
%   else
%      flag = false;
%   end
%
%   EXAMPLE 5: (copy into a file)
%
%   function demo
%   % Listen to zoom events
%   plot(1:10);
%   h = zoom;
%   h.ActionPreCallback = @myprecallback;
%   h.ActionPostCallback = @mypostcallback;
%   h.Enable = 'on';
%
%   function myprecallback(obj,evd)
%   disp('A zoom is about to occur.');
%
%   function mypostcallback(obj,evd)
%   newLim = evd.Axes.XLim;
%   msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim));
%
%   Use LINKAXES to link zooming across multiple axes.
%
%   See also PAN, ROTATE3D, LINKAXES.
%

% Copyright 1993-2017 The MathWorks, Inc.

% Internal use undocumented syntax (this may be removed in a future
% release)
% Additional syntax not already dead in zoom help
%
% ZOOM(FIG,'UIContextMenu',...)
%    Specify UICONTEXTMENU for use in zoom mode
% ZOOM(FIG,'Constraint',...)
%    Specify constrain option:
%       'none'       - No constraint (default)
%       'horizontal' - Horizontal zoom only for 2-D plots
%       'vertical'   - Vertical zoom only for 2-D plots
% ZOOM(FIG,'Direction',...)
%    Specify zoom direction 'in' or 'out'
% OUT = ZOOM(FIG,'IsOn')
%    Returns true if zoom is on, otherwise returns false.
% OUT = ZOOM(FIG,'Constraint')
%    Returns 'none','horizontal', or 'vertical'
% OUT = ZOOM(FIG,'Direction')
%    Returns 'in' or 'out'

% Undocumented syntax that will never get documented
% (but we have to keep it around for legacy reasons)
% OUT = ZOOM(FIG,'getmode') 'in'|'out'|'off'

import matlab.graphics.interaction.internal.*

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse input arguments
try
    [target, directive, parser_results] = zoom.parseArgs(nargout, varargin{:});
catch e
    throw(e);
end

if isempty(target)
    hFigure = gcf;
else
    hFigure = ancestor(target,'figure');
    if ishghandle(target,'axes')
        set(hFigure,'CurrentAxes',target);
    end
end
if ~matlab.uitools.internal.uimode.isLiveEditorFigure(hFigure)
    matlab.ui.internal.UnsupportedInUifigure(hFigure);
end


% Return early if setting zoom off and there's no app data
% this avoids making any objects or setting app data when
% it doesn't need to. For example, hgload calls zoom(fig,'off')
appdata = getappdata(hFigure,'ZoomOnState');
if directive && strcmp(parser_results.option,'off') && isempty(appdata)
    return;
end

% Get the mode object
hMode = locGetMode(hFigure);

% Get current axes
if ~ishghandle(hFigure)
    return;
end
hCurrentAxes = get(hFigure,'CurrentAxes');
hCurrentAxes = validateAxes(hCurrentAxes,'Zoom');

change_ui = [];
if directive % Single directive case
    % zoom(scale) case
    if isnumeric(parser_results.option) && ~isempty(hCurrentAxes)
        % Register current axes view for reset view support
        localStoreLimits(hCurrentAxes(1));
        hMode.fireActionPreCallback(localConstructEvd(hCurrentAxes));
        localApplyZoomFactor(hMode,hCurrentAxes,parser_results.option,false);
    else
        % Parse various zoom options
        switch lower(parser_results.option)

            case 'on'
                localChangeConstraint(hMode,'none');
                change_ui = 'on';

            case 'xon'
                localChangeConstraint(hMode,'horizontal');
                change_ui = 'on';

            case 'yon'
                localChangeConstraint(hMode,'vertical');
                change_ui = 'on';

            case 'getmode'
                if localIsZoomOn(hMode)
                    out = hMode.ModeStateData.Direction;
                else
                    out = 'off';
                end
            case 'constraint'
                out = hMode.ModeStateData.Constraint;
            case 'direction'
                out = hMode.ModeStateData.Direction;
            case 'ison'
                out = localIsZoomOn(hMode);
            case 'toggle'
                if localIsZoomOn(hMode)
                    change_ui = 'off';
                else
                    change_ui = 'on';
                end
            % Undocumented legacy API, used by 'ident', [194435]
            % TBD: Consider removing
            case 'down'
                localStartDrag(hMode,'dorightclick',true);
                hLine = hMode.ModeStateData.LineHandles;
                if any(ishghandle(hLine))
                    % Mimic rbbox, don't return until line handles are
                    % removed
                    waitfor(hLine(1));
                end
            case 'off'
                change_ui = 'off';
            case 'inmode'
                hX = uigettool(hFigure,'Exploration.ZoomX');
                if isempty(hX)
                    localChangeDirection(hMode,'in');
                else
                    hMode.ModeStateData.Direction = 'in';
                    localChangeConstraint(hMode,'none');
                end
                change_ui = 'on';
            case 'inmodex'
                hX = uigettool(hFigure,'Exploration.ZoomX');
                if isempty(hX)
                    localChangeDirection(hMode,'in');
                else
                    hMode.ModeStateData.Direction = 'in';
                    localChangeConstraint(hMode,'horizontal');
                end
                change_ui = 'on';
            case 'inmodey'
                hX = uigettool(hFigure,'Exploration.ZoomX');
                if isempty(hX)
                    localChangeDirection(hMode,'in');
                else
                    hMode.ModeStateData.Direction = 'in';
                    localChangeConstraint(hMode,'vertical');
                end
                change_ui = 'on';        
            case 'outmode'
                localChangeDirection(hMode,'out');
                change_ui = 'on';
            case 'fill'
                if ~isempty(hCurrentAxes)
                    localResetPlot(hCurrentAxes,hMode);
                end
            case 'reset'
                if ~isempty(hCurrentAxes)
                    matlab.graphics.interaction.internal.saveView(hCurrentAxes);
                    for i=1:numel(hCurrentAxes)
                        lims = calculateOrigLimits(hCurrentAxes(i));
                        setOrigLimits(hCurrentAxes(i), lims);
                    end
                end
            case 'out'
                if ~isempty(hCurrentAxes)
                    localResetPlot(hCurrentAxes,hMode);
                end
            case 'noaction'
                out = locGetObj(hFigure);
        end
    end
else % PV-pair case
    localSetZoomProperties(hMode,parser_results);
end

% Update the user interface
if ~isempty(change_ui)
    localSetZoomState(hFigure,change_ui);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%----------- Helper Functions for External API----------%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------%
function hZoom = locGetObj(hFig)
% Return the zoom accessor object, if it exists.
hMode = locGetMode(hFig);
if ~isfield(hMode.ModeStateData,'accessor') ||...
        ~ishandle(hMode.ModeStateData.accessor)
    % Call the appropriate mode accessor
    hZoom = matlab.graphics.interaction.internal.zoom(hMode);  
    hMode.ModeStateData.accessor = hZoom;
else
    hZoom = hMode.ModeStateData.accessor;
end

%-----------------------------------------------%
function localSetZoomProperties(hMode,propStruct)
% Set the properties of the mode as specified by user input.
% The input is in the form of a struct.
if propStruct.UIContextMenu ~= -1 % it was not given
	hMode.ModeStateData.CustomContextMenu = propStruct.UIContextMenu;
end
if ~isempty(propStruct.Direction)
    localChangeDirection(hMode,propStruct.Direction);
end
if ~isempty(propStruct.Constraint)
    localChangeConstraint(hMode,propStruct.Constraint);
end

%-----------------------------------------------%
function localResetPlot(hAxes,hMode)
import matlab.graphics.interaction.*

if ~all(ishghandle(hAxes))
    return;
end

% reset 2-D axes
if is2D(hAxes(1))
    origLim = getAxesLimits(hAxes);
    resetplotview(hAxes,'ApplyStoredView');
    newLim = getAxesLimits(hAxes);
    localCreate2DUndo(hMode.FigureHandle,hAxes,origLim,newLim);
    
% reset 3-D limit axes
elseif strcmp(internal.getAxes3DPanAndZoomStyle(hMode.FigureHandle,hAxes),'limits')
   origLim = getAxesLimits(hAxes);
   resetplotview(hAxes,'ApplyStoredView');
   newLim = getAxesLimits(hAxes);
   localCreate3DLimitUndo(hMode.FigureHandle,hAxes,origLim,newLim);
   
% reset 3-D camera axes   
else
    origVa = get(hAxes,'CameraViewAngle');
    origTarget = get(hAxes,'CameraTarget');
    resetplotview(hAxes,'ApplyStoredView');
    newVa = get(hAxes,'CameraViewAngle');
    newTarget = get(hAxes,'CameraTarget');
    localCreate3DCameraUndo(hAxes,origVa,newVa,origTarget,newTarget);
end
hMode.fireActionPostCallback(localConstructEvd(hAxes));

%-----------------------------------------------%
function localSetZoomState(hFig,state)

if strcmp(state,'on')
    activateuimode(hFig,'Exploration.Zoom');
    % zoom off
elseif strcmp(state,'off')
    if isactiveuimode(hFig,'Exploration.Zoom')
        activateuimode(hFig,'');
    end
end

%-----------------------------------------------%
function [bool] = localIsZoomOn(hMode)
fig = hMode.FigureHandle;
bool = true;
if isempty(hMode.ParentMode)
    if ~isactiveuimode(fig,'Exploration.Zoom')
        bool = false;
    end
end

%-----------------------------------------------%
function localChangeDirection(hMode,newValue)
%Modify the User interface if the direction is changed while the mode is
%running.

if localIsZoomOn(hMode)
    if strcmp(newValue,'in')
        localUISetZoomIn(hMode);
    elseif strcmp(newValue,'out')
        localUISetZoomOut(hMode);
    else
        error(message('MATLAB:zoom:InvalidDirection'));
    end
end
hMode.ModeStateData.Direction = newValue;

%-----------------------------------------------%
function localChangeConstraint(hMode,newValue)
%Modify the User interface if the constraint is changed while the mode is
%running.

newValue = lower(newValue);

if localIsZoomOn(hMode) && strcmpi(hMode.ModeStateData.Direction,'in')
    if strcmp(newValue,'none')
        localUISetZoomIn(hMode);
    elseif strcmp(newValue,'horizontal')
        localUISetZoomInX(hMode);
    elseif strcmp(newValue,'vertical')
        localUISetZoomInY(hMode);
    else
        error(message('MATLAB:zoom:InvalidConstraint'));
    end
end
hMode.ModeStateData.Constraint = newValue;

%-----------------------------------------------%
function [hMode] = locGetMode(hFig)
hMode = getuimode(hFig,'Exploration.Zoom');
if isempty(hMode)
    hMode = uimode(hFig,'Exploration.Zoom');
    set(hMode,'WindowButtonDownFcn',@(obj,evd)localWindowButtonDownFcn(obj,evd,hMode));
    set(hMode,'WindowButtonUpFcn',[]);
    set(hMode,'WindowButtonMotionFcn',@(obj,evd)localMotionFcn(obj,evd,hMode));
    set(hMode,'KeyPressFcn',@(obj,evd)localKeyPressFcn(obj,evd,hMode));
    set(hMode,'ModeStartFcn',@(~,~)localStartZoom(hMode));
    set(hMode,'ModeStopFcn',@(~,~)localStopZoom(hMode));
    set(hMode,'WindowScrollWheelFcn',@(obj,evd)localButtonWheelFcn(obj,evd,hMode));
    % Insert the default properties in the ModeStateData structure:
    hMode.ModeStateData.CustomContextMenu = [];
    hMode.ModeStateData.DoRightClick = getpref('MATLABZoom','RightClick','off');
    hMode.ModeStateData.Constraint = 'none';
    hMode.ModeStateData.Direction = 'in';
    hMode.ModeStateData.MotionRun = false;
    % Property for holding the RBBOX lines.
    hMode.ModeStateData.LineHandles = [];
    % Property storing original WindowButtonMotionFcn on 2D axes
    hMode.ModeStateData.OrigMotionFcn = [];
    % Property holding the axes handles of the last zoomed-in axes
    hMode.ModeStateData.CurrentAxes = [];
    % 3D Limit zoom properties
    hMode.ModeStateData.MotionEvd = [];
    % 3D Camera zoom properties
    hMode.ModeStateData.MaxViewAngle = 75;

    % Cache handles for faster performance
    hMode.ModeStateData.ToolbarZoomInButton = uigettool(hMode.FigureHandle,'Exploration.ZoomIn');
    hMode.ModeStateData.ToolbarZoomOutButton = uigettool(hMode.FigureHandle,'Exploration.ZoomOut');
    hMode.ModeStateData.ToolbarZoomXButton = uigettool(hMode.FigureHandle,'Exploration.ZoomX');
    hMode.ModeStateData.ToolbarZoomYButton = uigettool(hMode.FigureHandle,'Exploration.ZoomY');
    hMode.ModeStateData.MenuZoomIn = findall(hMode.FigureHandle,'Tag','figMenuZoomIn');
    hMode.ModeStateData.MenuZoomOut = findall(hMode.FigureHandle,'Tag','figMenuZoomOut');
end

%---------------------------------------------------------------------%
function localStartZoom(hMode)

hFigure = hMode.FigureHandle;

%Refresh context menu
hui = get(hMode,'UIContextMenu');
if ishghandle(hMode.ModeStateData.CustomContextMenu)
    set(hMode,'UIContextMenu',hMode.ModeStateData.CustomContextMenu);
elseif ishghandle(hui)
    delete(hui);
    set(hMode,'UIContextMenu','');
end

set(hMode,'WindowButtonUpFcn',[])

% Turn on Zoom UI (i.e. toolbar buttons, menus)
% This must be called AFTER uiclear to avoid uiclear state munging
zoom_direction = hMode.ModeStateData.Direction;
switch zoom_direction
    case 'in'
        zoom_constraint = hMode.ModeStateData.Constraint;
        switch zoom_constraint
            case 'none'
                localUISetZoomIn(hMode);
            case 'horizontal'
                localUISetZoomInX(hMode);
            case 'vertical'
                localUISetZoomInY(hMode);
        end
    case 'out'
        localUISetZoomOut(hMode);
end

% Define appdata to avoid breaking code in
% hgsave, and figtoolset
setappdata(hFigure,'ZoomOnState','on');

%---------------------------------------------------------------------%
function localStopZoom(hMode)

hFigure = hMode.FigureHandle;

%Edge case, we turn off the zoom while in drag-mode:
hLines = hMode.ModeStateData.LineHandles;
if any(ishghandle(hLines))
    delete(hLines);
end

% Turn off Zoom UI (i.e. toolbar buttons, menus)
localUISetZoomOff(hMode);

% Remove uicontextmenu
hui = get(hMode,'UIContextMenu');
if (~isempty(hui) && ishghandle(hui)) && ...
        (isempty(hMode.ModeStateData.CustomContextMenu) || ~ishghandle(hMode.ModeStateData.CustomContextMenu))
    delete(hui);
end

% Remove appdata to avoid breaking code in
% hgsave, and figtoolset
if isappdata(hFigure,'ZoomOnState')
    rmappdata(hFigure,'ZoomOnState');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%----------- 2D/3D Shared Helper Code----------%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------%
function localStoreLimits(hAxes)

hAxesList = hAxes;
% We need to take linked axes into account.
if isappdata(hAxes,'graphics_linkaxes') && ~isempty(getappdata(hAxes,'graphics_linkaxes'))
    linkAxesInfo = getappdata(hAxes,'graphics_linkaxes');
    if isa(linkAxesInfo.LinkProp,'matlab.graphics.internal.LinkProp')
        hAxesList = [hAxesList linkAxesInfo.LinkProp.Targets];  
    end
end
hAxesList = hAxesList(ishghandle(hAxesList));

for i=1:numel(hAxesList)
    matlab.graphics.interaction.internal.initializeView(hAxesList(i));
end

%-----------------------------------------------%
function factor = localGetZoomFactor(varargin)
factor = 3/2;
if (nargin == 1) && strcmpi(varargin{1},'out')
    factor = 1/factor;  
end

%-----------------------------------------------%
function factor = localGetScrollZoomFactor(varargin)
factor = 16/15;
if (nargin == 1) && strcmpi(varargin{1},'out')
    factor = 1/factor;  
end
    
%-----------------------------------------------%
function [ax] = locFindAxes(fig,evd)
% Return the axes that the mouse is currently over
% Return empty if no axes found (i.e. axes has hidden handle)

if ~ishghandle(fig)
    return;
end

% Return all axes under the current mouse point. When using MATLABClasses,
% if evd is not a WindowMouseData event (e.g if it is a MouseWheelEvent) 
% it will not have a HitPrimitive property and so localHittest cannot 
% be used. In this case determine the axes using the figure CurrentPoint 
% property.
allAxes = matlab.graphics.interaction.internal.hitAxes(fig, evd);
ax = [];
if ~isempty(allAxes)
    ax = matlab.graphics.interaction.internal.validateAxes(allAxes,'Zoom');
end

%-----------------------------------------------%
function new_pt = getPointInPixels(hFig,old_pt)
% eventdata information is always in pixels, so we must convert
if ~strcmpi(hFig.Units,'Pixels')
    ptrect = hgconvertunits(hFig, [0,0,old_pt], hFig.Units, 'Pixels', hFig);
    new_pt = ptrect(3:4);
else
    new_pt = old_pt;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%----------- 2D/3D Shared Callbacks----------%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------%
function localWindowButtonDownFcn(hFigure,evd,hMode)

fig_sel_type = get(hFigure,'SelectionType');
fig_mod = get(hFigure,'CurrentModifier');

hAxes = locFindAxes(hFigure,evd);

if isempty(hAxes)
    if strcmp(fig_sel_type,'alt')
        hMode.ShowContextMenu = false;
    end
    return;
end

switch (lower(fig_sel_type))
    case 'alt' % right click
        % display context menu
        if strcmpi(hMode.ModeStateData.DoRightClick,'off')
            localGetContextMenu(hMode);
        else
            hMode.ShowContextMenu = false;
            hMode.fireActionPreCallback(localConstructEvd(hAxes));
            localStartDrag(hMode,evd,true);
        end
    otherwise % left click, center click, double click
        % Zoom out if user clicked on 'alt' or shift
        % ToDo: Remove "alt" in a future release
        if ~isempty(fig_mod) && isscalar(fig_mod) && ...
                (strcmp(fig_mod,'alt') || strcmp(fig_mod,'shift'))
            for i=1:numel(hAxes)
               localStoreLimits(hAxes(i));
            end
            zoom_factor = localGetZoomFactor(hMode.ModeStateData.Direction);
            hMode.fireActionPreCallback(localConstructEvd(hAxes));
            if ~is2D(hAxes(1)) && strcmp(matlab.graphics.interaction.internal.getAxes3DPanAndZoomStyle(hFigure,hAxes),'limits')
                local3DLimitZoom(hFigure, hAxes, evd, 1/zoom_factor);
            else
                localApplyZoomFactor(hMode,hAxes,1/zoom_factor,true);
            end
        else
            hMode.fireActionPreCallback(localConstructEvd(hAxes));
            localStartDrag(hMode,evd);
        end
end

%---------------------------------------------------%
function localStartDrag(hMode,evd,dorightclick)
% Mouse Button Down Function

% By default, don't support right click zoom out
if nargin==1
  dorightclick = false;
end

hFig = hMode.FigureHandle;
hAxesVector = locFindAxes(hFig,evd);
if ~isempty(hAxesVector)
   hMode.ModeStateData.CurrentAxes = hAxesVector;
 
   sel_type = get(hFig,'SelectionType');
   switch sel_type

       case 'normal' % left click        
         if strcmpi(hMode.ModeStateData.Direction,'out') && is2D(hAxesVector(1))
             localApplyZoomFactor(hMode,hAxesVector,1/localGetZoomFactor,true);
         else
             localZoom(evd,hMode,hAxesVector);
         end
                    
       case 'open' % double click
          % Reset top plot
          localResetPlot(hAxesVector,hMode);
         
       case 'alt' % right click
          % zoom out
          if dorightclick
              if strcmpi(hMode.ModeStateData.Direction,'in') && is2D(hAxesVector(1))
                  localApplyZoomFactor(hMode,hAxesVector,1/localGetZoomFactor,false);
              else
                  localZoom(evd,hMode,hAxesVector);
              end
          end
          
       case 'extend' % center click
          % Do nothing 
   end
end

%---------------------------------------------------%
function localZoom(evd,hMode,hAxesVector)

for i=1:numel(hAxesVector)
    localStoreLimits(hAxesVector(i));
end

% Call appropriate zoom method based on whether plot is 2-D or 3-D plot.
% 2D callbacks can accept vectors of axes, 3D plots cannot.
if is2D(hAxesVector(1))
  localButtonDownFcn2D(evd,hMode,hAxesVector);
else
  localButtonDownFcn3D(evd,hMode,hAxesVector(1));
end

%-----------------------------------------------%
function localMotionFcn(obj,evd,hMode)
import matlab.graphics.interaction.internal.setPointer
hFigure = obj;
% Get current point in figure units
set(hFigure,'CurrentPoint',evd.Point);
hAx = locFindAxes(hFigure,evd);

if ~isempty(hAx)
    hAxes = hAx(1);
    behave_cons = getZoomBehaviorConstraint(hAxes);
    [~,cursorstyle] = matlab.graphics.interaction.internal.zoom.chooseConstraint(hAxes,hMode.ModeStateData.Constraint,behave_cons);
    cursor = constraintToCursorName(hAxes,cursorstyle,hMode.ModeStateData.Direction);
    setPointer(hFigure,cursor);
else
    setPointer(hFigure,'arrow');
end

hMode.ModeStateData.MotionEvd = evd;

function cursor = constraintToCursorName(ax,cons,dir)
if is2D(ax)
    cons = matlab.graphics.interaction.internal.constraintConvert3DTo2D(cons);
end
cursor = ['zoom' dir '_' cons];

%-------------------------------------------%
function localApplyZoomFactor(hMode,hAxesVector,zoom_factor,useCurrentPoint)
% hAxes is an axes vector
% zoom_factor is a scalar double

if ~isempty(hAxesVector) && ishghandle(hAxesVector(1))
    if is2D(hAxesVector(1))
        localZoomFactor2D(hMode.FigureHandle,hAxesVector,zoom_factor,hMode.ModeStateData.Constraint,useCurrentPoint)
    else
        hAxes = hAxesVector(1); %Only zoom one axes at a time in 3D
        if zoom_factor <= 0
            return;
        end
        hFig = hMode.FigureHandle;
        isLimitPanAndZoom = strcmp(matlab.graphics.interaction.internal.getAxes3DPanAndZoomStyle(hFig,hAxes),'limits');
        
        if isLimitPanAndZoom
            local3DLimitZoom(hFig,hAxes,[],zoom_factor)
        else
            local3DCameraZoom(hAxes,zoom_factor,hMode.ModeStateData.MaxViewAngle)
        end
    end
end

% Fire mode post callback function:
hMode.fireActionPostCallback(localConstructEvd(hAxesVector));

%-----------------------------------------------%
function localButtonWheelFcn(hFigure, evd, hMode)

hAxes = locFindAxes(hFigure,evd);
if isempty(hAxes)
    return;
end

dir = evd.VerticalScrollCount;
if dir < 0
    zoomFactor = localGetScrollZoomFactor;
else
    zoomFactor = 1/localGetScrollZoomFactor;
end

for i=1:numel(hAxes)
    localStoreLimits(hAxes(i));
end
hMode.fireActionPreCallback(localConstructEvd(hAxes));
isLimitPanAndZoom = strcmp(matlab.graphics.interaction.internal.getAxes3DPanAndZoomStyle(hFigure,hAxes),'limits');

if is2D(hAxes) 
    localApplyZoomFactor(hMode,hAxes,zoomFactor,true);
elseif isLimitPanAndZoom
    local3DLimitZoom(hFigure,hAxes,hMode.ModeStateData.MotionEvd,zoomFactor)
else
    localApplyZoomFactor(hMode,hAxes,zoomFactor,false)
end

%-----------------------------------------------%
function localKeyPressFcn(hFigure,evd,hMode)

consumekey = false;

% Exit early if invalid conditions
if ~isobject(evd) && (~isstruct(evd) || ~isfield(evd,'Key') || ...
    isempty(evd.Key) || ~isfield(evd,'Character'))
   return;
end

% Parse key press
zoomfactor = [];
switch evd.Key
    case 'uparrow'
        zoomfactor = localGetZoomFactor;      
    case 'downarrow'
        zoomfactor = 1/localGetZoomFactor;    
    case 'alt'
        consumekey = true;
    case 'escape'
        consumekey = true;
        localEnd2DDragZoom(hMode);  
    otherwise
        consumekey = matlab.graphics.interaction.internal.performUndoRedoKeyPress(hFigure,evd.Modifier,evd.Key);
end

hFigure = hMode.FigureHandle;
if ishghandle(hFigure)
    hAxes = hFigure.CurrentAxes;
    if ishghandle(hAxes)
        hAxes = matlab.graphics.interaction.internal.validateAxes(hAxes,'Zoom');
        if ~isempty(zoomfactor) && ~isempty(hAxes)
            consumekey = true;
            for i = 1:numel(hAxes)
                localStoreLimits(hAxes(i));
            end
            hMode.fireActionPreCallback(localConstructEvd(hAxes));
            localApplyZoomFactor(hMode,hAxes,zoomfactor,false);
        end
    end
end

if ~consumekey
    graph2dhelper('forwardToCommandWindow',hFigure,evd);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%----------- 2D Zoom----------%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------%
function localZoomFactor2D(hFig,hAxesVector,zoomFactor,modeConstraint,useCurrentPoint)
import matlab.graphics.interaction.*
for i = 1:numel(hAxesVector)
    localStoreLimits(hAxesVector(i));
end
origLimDatatyped = getAxesLimits(hAxesVector);

if zoomFactor < 0
    return
end

% Get bounding limits for zooming out.
transCurrLims = [0,1,0,1,0,1];
[transXLims, transYLims] = localCalculateZoomFactor2DLimits(hAxesVector(1),transCurrLims(1:2),transCurrLims(3:4),zoomFactor,useCurrentPoint);
[newXLims, newYLims] = internal.UntransformLimits(hAxesVector(1).ActiveDataSpace,transXLims,transYLims,[0,1]);

% Use constraints to throw out modified limits if necessary
currLims = matlab.graphics.interaction.getDoubleAxesLimits(hAxesVector(1));
behave_cons = getZoomBehaviorConstraint(hAxesVector(1));
zoomConstraint = internal.zoom.chooseConstraint(hAxesVector(1),modeConstraint,behave_cons);
if (strcmpi(zoomConstraint,'y'))
    newXLims = currLims(1:2);
end
if (strcmpi(zoomConstraint,'x'))
    newYLims = currLims(3:4);
end

localBoundPostProcessAndSet2DLimits(hAxesVector,currLims(1:2),currLims(3:4),newXLims,newYLims);
% Register with undo/redo
newLimDatatyped = getAxesLimits(hAxesVector);
localCreate2DUndo(hFig,hAxesVector,origLimDatatyped,newLimDatatyped);

%-------------------------------------------%
function [newXLims, newYLims] = localCalculateZoomFactor2DLimits(hAxes,currXLims,currYLims,zoomFactor,useCurrentPoint)
import matlab.graphics.interaction.*

if useCurrentPoint
    pts = hAxes.CurrentPoint; pts = pts(1,1:3);
    midpt = internal.TransformPoint(hAxes.ActiveDataSpace, pts(:));
else
    midpt = [mean(currXLims);mean(currYLims)];
end

% Calculate new x-limits and y-limits
newXLims = internal.zoom.zoomAxisAroundPoint(currXLims, midpt(1), zoomFactor);
newYLims = internal.zoom.zoomAxisAroundPoint(currYLims, midpt(2), zoomFactor);

%-------------------------------------------%
function localBoundPostProcessAndSet2DLimits(hAxesVector,currXLim,currYLim,newXLim,newYLim)
import matlab.graphics.interaction.internal.boundLimits
% Clamp limits to original or image limits
bounds = getBounds(hAxesVector(1), [currXLim, currYLim]);
newXLim = boundLimits(newXLim, bounds(1:2), false); 
newYLim = boundLimits(newYLim, bounds(3:4), false); 
localPostProcessAndSet2DLimits(hAxesVector,currXLim,currYLim,newXLim,newYLim);

%-------------------------------------------%
function localPostProcessAndSet2DLimits(hAxesVector,currXLim,currYLim,newXLim,newYLim)
import matlab.graphics.interaction.*
hAxes = hAxesVector(1);
if strcmp(get(hAxes,'dataaspectratiomode'),'manual')
    olddx = diff(currXLim);
    olddy = diff(currYLim);
    ratio = olddx / olddy;
    newdx = diff(newXLim);
    newdy = diff(newYLim);
    % Convert the dx and dy into pixel units
    % Since we are always dealing with 2-D axes, convert the data units
    % into normalized units by normalizing against the current limits of
    % the data.
    ndx = newdx / olddx;
    ndy = newdy / olddy;
    pixPosRect = getpixelposition(hAxes,true);
    pdx = pixPosRect(1) + pixPosRect(3)*ndx;
    pdy = pixPosRect(2) + pixPosRect(4)*ndy;
    % Use the larger axis of the zoom as a base, unless the other axes
    % hasn't moved.
    if (pdy > pdx && ~isequal(newYLim,currYLim)) || ...
            isequal(newXLim,currXLim)
        diffSize = ratio * newdy;
        diffDiff = newdx - diffSize;
        diffHalf = diffDiff / 2;
        newXLim(1) = newXLim(1) + diffHalf;
        newXLim(2) = newXLim(2) - diffHalf;
    else
        diffSize = newdx / ratio;
        diffDiff = newdy - diffSize;
        diffHalf = diffDiff / 2;
        newYLim(1) = newYLim(1) + diffHalf;
        newYLim(2) = newYLim(2) - diffHalf;
    end
    %If the camera view angle is set to be manual and axis equal has
    %been set, bad things may happen:
    set(hAxes,'CameraViewAngleMode','auto');
end

if all([currXLim, currYLim] == [newXLim, newYLim])
    return;
end

matlab.graphics.interaction.internal.setYYAxisInactiveYLimMode(hAxes,'manual');
if ~isscalar(hAxesVector) % Plotyy only!
    [~, secondaryYLim] = internal.getFiniteLimits(hAxesVector(2));
    
    % transform to linear (if necessary)
    firstYLog = strcmp(hAxesVector(1).YScale,'log');
    secondYLog = strcmp(hAxesVector(2).YScale,'log');    
    currYLimLinear = internal.getLinearData(currYLim,firstYLog);
    newYLimLinear = internal.getLinearData(newYLim,firstYLog);
    secondYLimLinear = internal.getLinearData(secondaryYLim,secondYLog);

    % Perform zoom on second axes
    zoomfac = diff(newYLimLinear)/diff(currYLimLinear);
    newoffset = (newYLimLinear(1) - currYLimLinear(1))/diff(currYLimLinear);
    diffsecond = diff(secondYLimLinear)*zoomfac;
    firstlim = secondYLimLinear(1) + diff(secondYLimLinear)*newoffset;
    secondYLimLinearZoomed = [firstlim, firstlim+diffsecond];
    
    % transform back to log (if necessary)
    secondYLim = internal.getLinearData(secondYLimLinearZoomed,secondYLog);
    
    validateAndSetLimits(hAxesVector(2), newXLim, secondYLim);
end

% Actual zoom operation
validateAndSetLimits(hAxes, newXLim, newYLim);

%-------------------------------------------%
function bounds = getBounds(hAxes, currLimits)
% if we are within the limits of the image, use those limits, else, if we
% are within the original limits, use those, otherwise, don't bound 

h = findobj(hAxes,'Type','image');
if ~isempty(h)
    image_bounds = getGraphicsExtents(hAxes);
    if ~isempty(image_bounds) && withinBounds(currLimits, image_bounds)
        bounds = image_bounds;
        return;
    end
end

bounds = nan(6,1);
orig_bounds = getappdata(hAxes,'zoom_zoomOrigAxesLimits');
if ~isempty(orig_bounds) && withinBounds(currLimits, orig_bounds)
    bounds = orig_bounds;
end

function boundLimits = withinBounds(limits, bounds)
boundLimits = isInsideOriginalLimits(limits(1:2), bounds(1:2)) && ...
              isInsideOriginalLimits(limits(3:4), bounds(3:4));

%-----------------------------------------------%
function localButtonDownFcn2D(evd,hMode,hAxesVector)
% Button down function for 2-D zooming
localZoom2DIn(evd,hMode,hAxesVector);

%---------------------------------------------------%
function localZoom2DIn(evd,hMode,hAxesVector)

hFig = hMode.FigureHandle;

% Get current point in pixels
new_pt = getPointInPixels(hFig,evd.Point);
buttonDownData.MousePoint = new_pt;

% First element in the currentAxes is the axes on the 
% top (on which the lines are drawn).
hAxes = hAxesVector(1);
buttonDownData.CurrentAxes = hAxesVector;

% Get the current point on this axes
cp = hAxes.CurrentPoint; cp = cp(1,1:2);
buttonDownData.DataPoint = cp;

% Get zoom lines
hLines = localCreateZoomLines(hAxes);
buttonDownData.LineHandles = hLines;
hMode.ModeStateData.LineHandles = hLines;

%For "zoom('down')" syntax to work:
if ~localIsZoomOn(hMode)
    buttonDownData.obj = hFig;
else
    buttonDownData.obj = hMode;
end

% Set the window button motion and up fcn's.
hMode.ModeStateData.OrigMotionFcn = get(buttonDownData.obj,'WindowButtonMotionFcn');
buttonDownData.ModeConstraint = hMode.ModeStateData.Constraint;

% Only perform this step if the zoom-state is changing (i.e, we are not
% stuck in drag-mode.
if ~iscell(hMode.ModeStateData.OrigMotionFcn) || ~isequal(hMode.ModeStateData.OrigMotionFcn{1}, @local2DButtonMotionFcn)
    set(buttonDownData.obj, 'WindowButtonMotionFcn', @(o,e)local2DButtonMotionFcn(o,e,buttonDownData));
    set(buttonDownData.obj, 'WindowButtonUpFcn', @(o,e)local2DButtonUpFcn(o,e,hMode,buttonDownData));
end

%---------------------------------------------------%
function [hLines] = localCreateZoomLines(hAxes)

% 1) The parent should be added after the the line object created and all
% its properties are set  since the object is being added to the axes
% before the properties are set and events like ObjectChildAdded are fired.
% Meanwhile, set the parent to empty. see 2 
lineprops.Parent = matlab.graphics.primitive.world.Group.empty;

lineprops.LineWidth = 1;
lineprops.Color =   [0.65 0.65 0.65];
lineprops.Tag = '_TMWZoomLines';
lineprops.HandleVisibility = 'off';
lineprops.XLimInclude = 'off';
lineprops.YLimInclude = 'off';
lineprops.ZLimInclude = 'off';
lineprops.HitTest = 'off';
lineprops.AlignVertexCenters = 'on';

lineprops.XData = zeros(1,0);
lineprops.YData = zeros(1,0);
lineprops.ZData = zeros(1,0);

hLines = matlab.graphics.primitive.Line(lineprops);

% 2) Now set the parent so that the fully created lines will appear on the
% axes and will be treated as zoom lines (_TMWZoomLines).
hLines.Parent = hAxes; 
drawnow expose;

% set the layer of the underlying primitive to front so that the lines are
% always visible
hLines.Edge.Layer = 'front';

% Mark this object as non-data so that it is ignored 
% by various tools such as basic fitting.
hBehavior = hgbehaviorfactory('DataDescriptor');
set(hBehavior,'Enable',false);
hgaddbehavior(hLines,hBehavior);

%---------------------------------------------------%
function local2DButtonMotionFcn(hFig,evd,buttonDownData)
% Mouse Button Motion Function
if isa(buttonDownData.obj,'matlab.uitools.internal.uimode')
    hFig.CurrentPoint = evd.Point;
end

% The first axes in currentAxes is the one on the top. On this axes the
% lines are to be drawn.
cAx = buttonDownData.CurrentAxes(1);
cp  = cAx.CurrentPoint; cp = cp(1,1:2);
x_currpt = cp(1);
y_currpt = cp(2);

dp = buttonDownData.DataPoint;
x_origpt = dp(1);
y_origpt = dp(2);

% The first point of line 1 is always the zoom origin.
% Edge case - If the line handles are invalid, return early.
hLines = buttonDownData.LineHandles;
if isempty(hLines) || any(~ishghandle(hLines))
   return;
end

% Using original and current point locations in pixels, determine if we
% should do auto-constrained zoom
orig_pt = buttonDownData.MousePoint;
curr_pt = getPointInPixels(hFig,evd.Point);
behave_cons = getZoomBehaviorConstraint(cAx);
cons = matlab.graphics.interaction.internal.zoom.chooseConstraint(cAx,buttonDownData.ModeConstraint,behave_cons);
constraint = matlab.graphics.interaction.internal.zoom.getAutoZoomConstraint(cAx,cons,orig_pt,curr_pt,15);

% Draw rbbox depending on mode.
switch(constraint)
    case {'unconstrained'}
        % Both x and y zoom.
        % RBBOX - lines:
        % 
        %          2
        %    o-------------
        %    |            |
        %  1 |            | 4
        %    |            |
        %    --------------
        %          3
        %

        % Use real in case of negative log
        hLines.XData = real([x_origpt, x_origpt, x_currpt, x_currpt, x_origpt]);
        hLines.YData = real([y_origpt, y_currpt, y_currpt, y_origpt, y_origpt]);
        
    case 'x'
        % x only zoom.
        % RBBOX - lines (only 1-3 used):
        %   
        %    |     1      |
        %  2 o------------| 3 
        %    |            |
        %    
        
        isylog = strcmpi(cAx.YScale,'log');
        ylims = ruler2num(cAx.YLim, cAx.ActiveYRuler);
        y_end = getEndLineData(isylog, ylims, y_origpt);
        % 2, NaN, 1, NaN, 3 
        hLines.XData = real([x_origpt, x_origpt, NaN, x_origpt, x_currpt, NaN, x_currpt, x_currpt]);
        hLines.YData = real([y_end, NaN, y_origpt, y_origpt, NaN, y_end]);
        
    case 'y'
        % y only zoom.
        % RBBOX - lines (only 1-3 used):
        %    2
        %  --o--  
        %    |
        %  1 |
        %    |
        %  -----           
        %    3
        %
        
        isxlog = strcmpi(cAx.XScale,'log');
        xlims = ruler2num(cAx.XLim, cAx.ActiveXRuler);
        x_end = getEndLineData(isxlog, xlims, x_origpt);
        % 2, NaN, 1, NaN, 3
        hLines.YData = real([y_origpt, y_origpt, NaN, y_origpt, y_currpt, NaN, y_currpt, y_currpt]);
        hLines.XData = real([x_end, NaN, x_origpt, x_origpt, NaN, x_end]);        
end

%---------------------------------------------------%
function endpt = getEndLineData(islog, limits, origpt)

if islog
    limits = log10(limits);
    origpt_linear = log10(origpt);
else
    origpt_linear = origpt;
end

endHalfLength = (limits(2) - limits(1)) / 40;
endpt = [origpt_linear - endHalfLength, origpt_linear + endHalfLength];

if islog
    endpt = 10.^endpt;
end
        
%---------------------------------------------------%
function local2DButtonUpFcn(~,evd,hMode,buttonDownData)
% Mouse button up function  
import matlab.graphics.interaction.*
    
hFig = hMode.FigureHandle;
obj = buttonDownData.obj;

localEnd2DDragZoom(obj);

% Get necessary handles
currentAxes = buttonDownData.CurrentAxes;

% Get net mouse movement in pixels
fp = getPointInPixels(hFig,evd.Point);
orig_fp = buttonDownData.MousePoint;
dpixel = abs(orig_fp-fp);

% This constant specifies the number of pixels the mouse
% must move in order to do a bounding box zoom.
POINT_MODE_MAX_PIXELS = 15; % pixels

% Need to determine if we are in point-mode zoom or rbbox zoom. We will
% assume that the constraint of the top axes is the same constraint for all
% axes in the list:
behave_cons = getZoomBehaviorConstraint(currentAxes);
constraint = internal.zoom.chooseConstraint(currentAxes(1),buttonDownData.ModeConstraint,behave_cons);
constraintVal = internal.zoom.getAutoZoomConstraint(currentAxes(1),constraint,orig_fp,fp,POINT_MODE_MAX_PIXELS);
switch constraintVal
    case 'x'
        pointMode = dpixel(1)  <= POINT_MODE_MAX_PIXELS;
    case 'y'
        pointMode = dpixel(2) <= POINT_MODE_MAX_PIXELS;
    otherwise
        pointMode = (dpixel(1) <= POINT_MODE_MAX_PIXELS) ...
            && (dpixel(2) <= POINT_MODE_MAX_PIXELS);
end

if pointMode
    localApplyZoomFactor(hMode,currentAxes,localGetZoomFactor,true);
    return;
end

origin = buttonDownData.DataPoint;

% Loop through all the currentAxes and zoom-in each of them
% Get the current limits.
cAx = currentAxes(1);
currLim = getDoubleAxesLimits(cAx);

currentXLim = currLim(1:2);
currentYLim = currLim(3:4);
newXLim = currentXLim;
newYLim = currentYLim;

% Get current point.
cp = cAx.CurrentPoint; cp = cp(1,1:2);
xcp = cp(1);
ycp = cp(2);

% Perform zoom operation based on zoom mode.
switch(lower(constraintVal))
    case 'unconstrained'
        %
        % Both x and y zoom.
        % RBBOX - lines:
        %
        %          2
        %    o-------------
        %    |            |
        %  1 |            | 4
        %    |            |
        %    --------------
        %          3
        %
        
        % Uncomment to clip rbbox zoom to current axes limits
        %if xcp > currentXLim(2),
        %    xcp = currentXLim(2);
        %end
        %if xcp < currentXLim(1),
        %    xcp = currentXLim(1);
        %end
        %if ycp > currentYLim(2),
        %    ycp = currentYLim(2);
        %end
        %if ycp < currentYLim(1),
        %    ycp = currentYLim(1);
        %end
        endPt = [xcp ycp];
        
        newXLim = sort([origin(1),endPt(1)]);
        newYLim = sort([origin(2),endPt(2)]);
        
    case 'x'
        % x only zoom.
        % RBBOX - lines (only 1-3 used):
        %
        %    |     1      |
        %  2 o------------| 3
        %    |            |
        %
        %
        
        % Uncomment to clip rbbox zoom to current axes limits
        % if xcp > currentXLim(2),
        %    xcp = currentXLim(2);
        % end
        % if xcp < currentXLim(1),
        %    xcp = currentXLim(1);
        % end
        
        newXLim = sort([origin(1),xcp]);
        
    case 'y'
        % y only zoom.
        % RBBOX - lines (only 1-3 used):
        %    2
        %  --o--
        %    |
        %  1 |
        %    |
        %  -----
        %    3
        %
        
        % Uncomment to clip rbbox zoom to current axes limits
        % if ycp > currentYLim(2),
        %    ycp = currentYLim(2);
        % end
        % if ycp < currentYLim(1),
        %    ycp = currentYLim(1);
        % end
        
        newYLim = sort([origin(2),ycp]);
end % switch

currLimDatatyped = getAxesLimits(currentAxes);
localBoundPostProcessAndSet2DLimits(currentAxes,currentXLim,currentYLim,newXLim,newYLim);
% Fire mode post callback function:
hMode.fireActionPostCallback(localConstructEvd(currentAxes));

% Use datatyped axes limits for undo/redo
newLimDatatyped = getAxesLimits(currentAxes);
localCreate2DUndo(hFig,currentAxes,currLimDatatyped,newLimDatatyped);

% Turn back on axes dirty listeners to dirty the legend when an axes
% property changes
internal.toggleAxesLayoutManager(hFig,currentAxes,true);

%---------------------------------------------------%
function localEnd2DDragZoom(hMode)

if ~isa(hMode,'matlab.uitools.internal.uimode')
    return;
end

% Delete the bounding box lines.
if ~isempty(hMode.ModeStateData.LineHandles) && all(ishghandle(hMode.ModeStateData.LineHandles))
    delete(hMode.ModeStateData.LineHandles);
end

set(hMode,'WindowButtonMotionFcn',hMode.ModeStateData.OrigMotionFcn);
set(hMode,'WindowButtonUpFcn','');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%----------- 3D Zoom Shared Callbacks----------%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------%
function localButtonDownFcn3D(evd,hMode,hAxes)
% Button down function for 3-D zooming
import matlab.graphics.interaction.*

hFig = hMode.FigureHandle;
buttonDownData.isLimitPanAndZoom = strcmp(internal.getAxes3DPanAndZoomStyle(hFig,hAxes),'limits');
buttonDownData.Direction = hMode.ModeStateData.Direction;
curr_pixels = getPointInPixels(hMode.FigureHandle,evd.Point);
buttonDownData.MousePoint = curr_pixels;

if buttonDownData.isLimitPanAndZoom % limit zoom
    % To avoid strange behavior, change CameraTarget and CameraViewAngle back to auto
    hAxes.CameraTargetMode = 'auto';
    hAxes.CameraPositionMode = 'auto';
    behave_cons = getZoomBehaviorConstraint(hAxes);
    buttonDownData.Constraint = internal.zoom.chooseConstraint(hAxes,hMode.ModeStateData.Constraint,behave_cons);

    buttonDownData.Orig3DLimitsDatatyped = getAxesLimits(hAxes);
    
    localStoreLimits(hAxes);
    
    buttonDownData.DataSpace = internal.copyDataSpace(hAxes.ActiveDataSpace); 
    
    bounds = getappdata(hAxes,'zoom_zoomOrigAxesLimits');
    [tbounds(1:2), tbounds(3:4), tbounds(5:6)] = internal.TransformLimits(hAxes.ActiveDataSpace, bounds(1:2), bounds(3:4), bounds(5:6));
    buttonDownData.Bounds = bounds;
    buttonDownData.Transformed_Bounds = tbounds;
    
    % Get current point in pixel units
    orig_limits = getDoubleAxesLimits(hAxes);
    untrans_pt = internal.zoom.chooseLimitZoom3DPoint(orig_limits, evd, hAxes);
    buttonDownData.Transformed_Point = internal.TransformPoint(hAxes.ActiveDataSpace,untrans_pt);
    
else % camera zoom
    % Set the original camera view angle
    % We'll need this for generating the undo/redo
    % command object.
    buttonDownData.DataAspectRatio = hAxes.DataAspectRatio;
    buttonDownData.CameraViewAngle = hAxes.CameraViewAngle;
    buttonDownData.CameraPosition = hAxes.CameraPosition;
    buttonDownData.CameraTarget = hAxes.CameraTarget;
    buttonDownData.MaxViewAngle = hMode.ModeStateData.MaxViewAngle;
    % Force axis to be 'vis3d' to avoid wacky resizing
    axis(hAxes,'vis3d');
end

% Turn off axes dirty listeners for performance when a legend is
% present
internal.toggleAxesLayoutManager(hFig,hAxes,false);

hMode.ModeStateData.MotionRun = false;

% Set the window button motion and up fcn's.
buttonDownData.origMotionFcn = get(hMode,'WindowButtonMotionFcn');
if buttonDownData.isLimitPanAndZoom % limit zoom
    set(hMode, 'WindowButtonMotionFcn',@(obj,evd)local3DLimitButtonMotionFcn(obj,evd,hMode,hAxes,buttonDownData));
else
    set(hMode, 'WindowButtonMotionFcn',@(obj,evd)local3DCameraButtonMotionFcn(obj,evd,hMode,hAxes,buttonDownData));
end
set(hMode, 'WindowButtonUpFcn', @(obj,evd)local3DButtonUpFcn(obj,evd,hMode,hAxes,buttonDownData));        

%---------------------------------------------------%
function local3DButtonUpFcn(hFig, evd, hMode, hAxes, buttonDownData)

% If the mouse position never moved then just zoom in
% on the mouse click
if ~hMode.ModeStateData.MotionRun
    localOneShot3DZoom(hFig,hAxes,evd,buttonDownData); 
elseif buttonDownData.isLimitPanAndZoom
    hAxes = hAxes(1); % only one axes can be zoomed at a time.
    origLim = buttonDownData.Orig3DLimitsDatatyped;
    newLim = matlab.graphics.interaction.getAxesLimits(hAxes);
    localCreate3DLimitUndo(hFig,hAxes,origLim,newLim);
else
    % Add zoom operation to undo/redo stack
    origVa = buttonDownData.CameraViewAngle;
    newVa = get(hAxes,'CameraViewAngle');
    localCreate3DCameraUndo(hAxes,origVa,newVa);
end

% Turn back on axes dirty listeners to dirty the legend when an axes
% property changes
matlab.graphics.interaction.internal.toggleAxesLayoutManager(hFig,hAxes,true);

set(hMode,'WindowButtonUpFcn','');
set(hMode,'WindowButtonMotionFcn',buttonDownData.origMotionFcn);

% Fire mode post callback function:
hMode.fireActionPostCallback(localConstructEvd(hAxes));

%---------------------------------------------------%
function localOneShot3DZoom(hFig,hAxes,evd,buttonDownData)
% If button motion function never ran then do a 
% simple 3D zoom based on current mouse position

zoomLeftFactor = localGetZoomFactor(buttonDownData.Direction);
zoomRightFactor = 1/zoomLeftFactor;         

fac = [];
% Determine new zoom factor based on mouse click
switch hFig.SelectionType   
   case 'normal' % Left click
      fac = zoomLeftFactor;

   case 'open' % Double click
        % do nothing

   otherwise % Right click
      fac = zoomRightFactor;
end
if isempty(fac)
    return;
end

if buttonDownData.isLimitPanAndZoom  % limit zoom
    local3DLimitZoom(hFig,hAxes,evd,fac);
else % camera zoom
    local3DCameraZoomOnCurrentPoint(hAxes,fac,buttonDownData.MaxViewAngle);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%----------- 3D Limit Zoom----------%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------%
function local3DLimitButtonMotionFcn(~,evd,hMode,hAxes,buttonDownData)
import matlab.graphics.interaction.*
hMode.ModeStateData.MotionRun = true;

starting_pt = buttonDownData.MousePoint;
curr_pixels = getPointInPixels(hMode.FigureHandle,evd.Point);

xy = sum(curr_pixels - starting_pt);
DAMPING = 300;  % how many pixels I have to go to double the zoom factor
zoom_factor = 2.^(xy/DAMPING);

orig_limits = [0,1,0,1,0,1];
trans_limits = local3DZoomAroundPoint(orig_limits, buttonDownData.Transformed_Point, zoom_factor, buttonDownData.Constraint, buttonDownData.Transformed_Bounds);
if all(orig_limits == trans_limits)
    return;
end
[x,y,z] = internal.UntransformLimits(buttonDownData.DataSpace,trans_limits(1:2),trans_limits(3:4),trans_limits(5:6));
validateAndSetLimits(hAxes,x,y,z);

%---------------------------------------------------%
function cons_limits = local3DZoomAroundPoint(orig_limits, pt, zoom_factor, constraint, bounds)
new_limits = matlab.graphics.interaction.internal.zoom.zoomAroundPoint3D(orig_limits, pt, zoom_factor);

% If all limits are inside of original limits, bound them to original
% limits
bound_lim = isInsideOriginalLimits(orig_limits(1:2), bounds(1:2)) && ...
            isInsideOriginalLimits(orig_limits(3:4), bounds(3:4)) && ...
            isInsideOriginalLimits(orig_limits(5:6), bounds(5:6));

if ~bound_lim
    bounds = nan(numel(bounds));
end

new_xlim = matlab.graphics.interaction.internal.boundLimits(new_limits(1:2), bounds(1:2), false);
new_ylim = matlab.graphics.interaction.internal.boundLimits(new_limits(3:4), bounds(3:4), false);
new_zlim = matlab.graphics.interaction.internal.boundLimits(new_limits(5:6), bounds(5:6), false);
cons_limits = localConstrainZoom(constraint, orig_limits, [new_xlim, new_ylim, new_zlim]);       

%---------------------------------------------------%
function inside = isInsideOriginalLimits(origlim, bounds)
inside = false;
tolerance = 1e-2;
if origlim(1) + tolerance >= bounds(1) && origlim(2) <= bounds(2) + tolerance
    inside = true;
end

%---------------------------------------------------%
function cons_limits = localConstrainZoom(constraint, orig_limits, new_limits)
cons_limits = orig_limits;
if any(strcmp(constraint,{'unconstrained'}))
    cons_limits = new_limits;
else
    if any(strcmp(constraint,{'x','xy','xz'}))
        cons_limits(1:2) = new_limits(1:2);
    end
    if any(strcmp(constraint,{'y','xy','yz'}))
        cons_limits(3:4) = new_limits(3:4);
    end
    if any(strcmp(constraint,{'z','xz','yz'}))
        cons_limits(5:6) = new_limits(5:6);
    end
end

%-----------------------------------------------%
function local3DLimitZoom(hFig,hAxes,evd,zoom_factor)
% Find axes limits to zoom in to the figure CurrentPoint by a zoom factor
% zoom_factor using the DataAnnotatable interface.
import matlab.graphics.interaction.*

hAxes = hAxes(1);
origLimDataTyped = getAxesLimits(hAxes);
transOrigLim = [0,1,0,1,0,1];

orig_limits = getDoubleAxesLimits(hAxes);
untrans_pt = internal.zoom.chooseLimitZoom3DPoint(orig_limits, evd, hAxes);
pt = internal.TransformPoint(hAxes.ActiveDataSpace,untrans_pt);

behave_cons = getZoomBehaviorConstraint(hAxes);
constraint = internal.zoom.chooseConstraint(hAxes,'unconstrained',behave_cons);

untrans_bounds = getappdata(hAxes,'zoom_zoomOrigAxesLimits');
[bounds(1:2), bounds(3:4), bounds(5:6)] = internal.TransformLimits(hAxes.ActiveDataSpace,untrans_bounds(1:2),untrans_bounds(3:4),untrans_bounds(5:6));
if all(isfinite(pt)) %evd.Point can return NaN if the view is really strange
    transNewLim = local3DZoomAroundPoint(transOrigLim, pt, zoom_factor, constraint, bounds);
else
    return
end

% do not set limits or add to undo stack if limits are the same as bounds
if all(transOrigLim == transNewLim)
    return;
end

[x,y,z] = internal.UntransformLimits(hAxes.ActiveDataSpace,transNewLim(1:2),transNewLim(3:4),transNewLim(5:6));
validateAndSetLimits(hAxes,x,y,z);
newLimDataTyped = getAxesLimits(hAxes);
localCreate3DLimitUndo(hFig,hAxes,origLimDataTyped,newLimDataTyped);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%----------- 3D Camera Zoom----------%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------%
function local3DCameraButtonMotionFcn(hFig,eventData,hMode,hAxes,buttonDownData)
hMode.ModeStateData.MotionRun = true;

% Get current point in pixels
curr_pt = getPointInPixels(hFig,eventData.Point);
start_pt = buttonDownData.MousePoint;

% Determine change in pixel position
xy = curr_pt - start_pt;

% Heuristic for pixel change to camera zoom factor
q = 2.^(sum(xy)/70);
max_angle = hMode.ModeStateData.MaxViewAngle;
newva = localCalculate3DCameraZoom(q,max_angle,buttonDownData,false);
hAxes.CameraViewAngle = newva;

%-----------------------------------------------%
function local3DCameraZoomOnCurrentPoint(hAxes,fac,maxAngle)

%Check to see if the new camera target is within the bounds of the axes. If
%it is not, zoom based on the current target.
[xlimit, ylimit, zlimit] = matlab.graphics.interaction.internal.getFiniteLimits(hAxes);
buttonDownData.Limits = [xlimit, ylimit, zlimit];
    
buttonDownData.DataAspectRatio = hAxes.DataAspectRatio;
buttonDownData.CameraViewAngle = hAxes.CameraViewAngle;
buttonDownData.CameraPosition  = hAxes.CameraPosition;
buttonDownData.CameraTarget    = hAxes.CameraTarget;
buttonDownData.CurrentPoint    = hAxes.CurrentPoint;

if any(~isfinite(buttonDownData.CurrentPoint))
    return; % axes view is invalid. Return and don't even add this to the undo stack
end
    
% Actual zoom operation
[newva, newct, newcp] = localCalculate3DCameraZoom(fac,maxAngle,buttonDownData,true);
hAxes.CameraViewAngle = newva;
hAxes.CameraTarget = newct;
hAxes.CameraPosition = newcp;

% Add operation to undo/redo stack
localCreate3DCameraUndo(hAxes,buttonDownData.CameraViewAngle,newva,buttonDownData.CameraTarget,newct);

%-------------------------------------------%
function local3DCameraZoom(hAxes,zoom_factor,maxAngle)

buttonDownData.DataAspectRatio = hAxes.DataAspectRatio;
buttonDownData.CameraViewAngle = hAxes.CameraViewAngle;
buttonDownData.CameraPosition  = hAxes.CameraPosition;
buttonDownData.CameraTarget    = hAxes.CameraTarget;

% Actual zoom operation
newva = localCalculate3DCameraZoom(zoom_factor,maxAngle,buttonDownData,false);
hAxes.CameraViewAngle = newva;

% Add operation to undo/redo stack
localCreate3DCameraUndo(hAxes,buttonDownData.CameraViewAngle,newva);

%-----------------------------------------------%
function [newVa, newCt, newCp] = localCalculate3DCameraZoom(zoom_factor,MAX_VIEW_ANGLE,buttonDownData,useCurrentPoint)

newCt = buttonDownData.CameraTarget;
newCp = buttonDownData.CameraPosition;
if useCurrentPoint
    currPt = mean(buttonDownData.CurrentPoint);
    if matlab.graphics.interaction.isPointWithinLimits(currPt, buttonDownData.Limits)
        newCt = currPt;
        ctDiff = newCt - buttonDownData.CameraTarget;
        newCp = buttonDownData.CameraPosition + ctDiff;
    end
end
newVa = camZoom(zoom_factor, buttonDownData.DataAspectRatio, ...
                             buttonDownData.CameraViewAngle, ...
                             newCp, ...
                             newCt);

% heuristic avoids small view angles.
MIN_VIEW_ANGLE = .001;

%If the act of zooming puts us past extreme, put at max
if newVa >= MAX_VIEW_ANGLE
    newVa = MAX_VIEW_ANGLE;
elseif newVa <= MIN_VIEW_ANGLE
    newVa = MIN_VIEW_ANGLE;
end

%-----------------------------------------------%
function newcva = camZoom(zf, dar, cva, cp, ct)

v  = (ct-cp)./dar;
dis = norm(v);
fov = 2*dis*tan(cva/2*pi/180);

newcva = 2*atan((fov/zf/2)/dis)*180/pi;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%----------- Undo----------%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------%
function evd = localConstructEvd(hAxes)
% Construct event data for post callback
evd.Axes = hAxes;

%-----------------------------------------------%
function localCreate2DUndo(hFigure,hAxes,origLim,newLim)

% Don't add operations that don't change limits
% Assumption: if one axes didn't change, it is likely none of them did
if isequal(origLim{1}{1},newLim{1}{1}) && ...
   isequal(origLim{1}{2},newLim{1}{2})
  return;
end

% Determine undo stack name (this will appear in menu).  Use English for
% the name, it will get translated later on when it is used in the
% Undo/Redo menu items.
xruler = hAxes.ActiveXRuler;
yruler = hAxes.ActiveYRuler;
if lessThan(xruler, origLim{1}{1}(1), newLim{1}{1}(1)) && ...
        lessThan(yruler, origLim{1}{2}(1), newLim{1}{2}(1)) && ...
        lessThan(xruler, newLim{1}{1}(2), origLim{1}{1}(2)) && ...
        lessThan(yruler, newLim{1}{2}(2), origLim{1}{2}(2))
   name = 'Zoom In'; 
else
   name = 'Zoom Out';
end


% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
proxyVal = getProxyValueFromHandle(hAxes);

% Create command structure
cmd.Name = name;

if numel(hAxes(1).YAxis) < 2
    cmd.Function = @localDo2DUndo;
    cmd.Varargin = {hFigure,proxyVal,origLim,newLim};
    cmd.InverseFunction = @localDo2DUndo;
    cmd.InverseVarargin = {hFigure,proxyVal,newLim,origLim};
else
    origSide = hAxes.YAxisLocation;
    cmd.Function = @matlab.graphics.interaction.internal.doYYAxisUndo;
    cmd.Varargin = {@localDo2DUndo,hFigure,proxyVal,origSide,origLim,newLim};
    cmd.InverseFunction = @matlab.graphics.interaction.internal.doYYAxisUndo;
    cmd.InverseVarargin = {@localDo2DUndo,hFigure,proxyVal,origSide,newLim,origLim};
end

% Register with undo/redo
uiundo(hFigure,'function',cmd);

%-----------------------------------------------%
function localCreate3DLimitUndo(hFigure,hAxes,origLim,newLim)

origLim = origLim{1};
newLim = newLim{1};

% we need to look at 2d cases here in case someone resets into a 2d view
now2d = numel(newLim) == 2;

% Don't add operations that don't change limits
if (now2d && isequal(origLim{1},newLim{1}) && isequal(origLim{2},newLim{2})) || ...
   (~now2d && isequal(origLim{1},newLim{1}) && isequal(origLim{2},newLim{2}) && isequal(origLim{3},newLim{3}))
  return;
end

% Determine undo stack name (this will appear in menu).  Use English for
% the name, it will get translated later on when it is used in the
% Undo/Redo menu items.
xruler = hAxes.ActiveXRuler;
yruler = hAxes.ActiveYRuler;
if isprop(hAxes,'ActiveZRuler')
    zruler = hAxes.ActiveZRuler;
else
    zruler = [];
end
if lessThan(xruler, origLim{1}(1), newLim{1}(1)) || ...
        lessThan(yruler, origLim{2}(1), newLim{2}(1)) || ...
        lessThan(xruler, newLim{1}(2), origLim{1}(2)) || ...
        lessThan(yruler, newLim{2}(2), origLim{2}(2)) || ...
   (~now2d && (lessThan(zruler, origLim{3}(1), newLim{3}(1)) || lessThan(zruler, newLim{3}(2), origLim{3}(2))))
   name = 'Zoom In';
else
   name = 'Zoom Out';
end

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
proxyVal = getProxyValueFromHandle(hAxes);

% Create command structure
cmd.Name = name;
cmd.Function = @localDo3DLimitUndo;
cmd.Varargin = {hFigure,proxyVal,newLim};

if now2d
    cmd.InverseFunction = @localDo2DUndo;
    cmd.InverseVarargin = {hFigure,proxyVal,{newLim},{origLim}};
else % 3D
    cmd.InverseFunction = @localDo3DLimitUndo;    
    cmd.InverseVarargin = {hFigure,proxyVal,origLim};
end

% Register with undo/redo
uiundo(hFigure,'function',cmd);

%---------------------------------------------------%
function localDo2DUndo(hFig,proxyVal,origLim,newLim)

hAxesVector = getHandleFromProxyValue(hFig,proxyVal);
for i=1:length(hAxesVector)
    hAxes = hAxesVector(i);
    if ishghandle(hAxes)
        localPostProcessAndSet2DLimits(hAxes,origLim{i}{1},origLim{i}{2},newLim{i}{1},newLim{i}{2});
    end
end

%---------------------------------------------------%
function localDo3DLimitUndo(hFig,proxyVal,newLim)

hAxesVector = getHandleFromProxyValue(hFig,proxyVal);

hAxes = hAxesVector(1);
% No validation of limits needed here since they were valid at some point
% in the past.
if ishghandle(hAxes)
    hAxes.XLim = newLim{1};
    hAxes.YLim = newLim{2};
    hAxes.ZLim = newLim{3};
end

%---------------------------------------------------%
function localCreate3DCameraUndo(hAxes,origVa,newVa,origTarget,newTarget)

if nargin==3
   localViewAngleUndo(hAxes,origVa,newVa);
elseif nargin==5
   localTargetViewAngleUndo(hAxes,origVa,newVa,origTarget,newTarget);
end

%---------------------------------------------------%
function localTargetViewAngleUndo(hAxes,...
                                    origVa,newVa,...
                                    origCamTarget,newCamTarget)

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
hFigure = ancestor(hAxes(1),'figure');
proxyVal = getProxyValueFromHandle(hAxes);

if ~iscell(origVa)
    origVa = {origVa};
    newVa = {newVa};
end
if ~iscell(origCamTarget)
    origCamTarget = {origCamTarget};
    newCamTarget = {newCamTarget};
end

% Create command structure. Use English for the name, it will get
% translated later on when it is used in the Undo/Redo menu items.
cmd.Name = '3-D Zoom';
cmd.Function = @localUpdateCameraTargetViewAngle;
cmd.Varargin = {hFigure,proxyVal,newCamTarget,newVa};
cmd.InverseFunction = @localUpdateCameraTargetViewAngle;
cmd.InverseVarargin = {hFigure,proxyVal,origCamTarget,origVa};

uiundo(hFigure,'function',cmd);

%---------------------------------------------------%
function localUpdateCameraTargetViewAngle(hFig,proxyVal,t,va)

hAxes = getHandleFromProxyValue(hFig,proxyVal);

for i = 1:length(hAxes)
    if ishghandle(hAxes(i))
        camtarget(hAxes(i),t{i});
        camva(hAxes(i),va{i});
    end
end

%---------------------------------------------------%
function localViewAngleUndo(hAxes,origVa,newVa)

hFigure = ancestor(hAxes(1),'figure');

if ~iscell(origVa)
    origVa = {origVa};
    newVa = {newVa};
end

% Don't add operations that don't change limits
if isequal(origVa{1},newVa{1})
  return
end

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
proxyVal = getProxyValueFromHandle(hAxes);

% Create command structure. Use English for the name, it will get
% translated later on when it is used in the Undo/Redo menu items.
cmd.Name = '3-D Zoom';
cmd.Function = @localDoViewAngleUndo;
cmd.Varargin = {hFigure,proxyVal,newVa};
cmd.InverseFunction = @localDoViewAngleUndo;
cmd.InverseVarargin = {hFigure,proxyVal,origVa};

% Register with undo/redo
uiundo(hFigure,'function',cmd);

%-----------------------------------------------%
function localDoViewAngleUndo(hFig,proxyVal,origVa)

hAxes = getHandleFromProxyValue(hFig,proxyVal);

for i = 1:length(hAxes)
    if ishghandle(hAxes(i))
        camva(hAxes(i),origVa{i});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%-------Context Menu-------%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------%
function [hui] = localUICreateDefaultContextMenu(hMode)
% Create default context menu
hFig = get(hMode,'FigureHandle');
props_context.Parent = hFig;
props_context.Tag = 'ZoomContextMenu';
props_context.Serializable = 'off';
props_context.Callback = {@localUIContextMenuCallback,hMode};
props_context.ButtonDown = {@localUIContextMenuCallback,hMode};
hui = uicontextmenu(props_context);

% Generic attributes for all zoom context menus
props.Callback = {@localUIContextMenuCallback,hMode};
props.Parent = hui;

props.Label = getString(message('MATLAB:uistring:zoom:ZoomOutShiftClick'));
props.Tag = 'ZoomInOut';
props.Separator = 'off';
zoomout = uimenu(props);

% Full View context menu
props.Label = getString(message('MATLAB:uistring:zoom:ResetToOriginalView'));
props.Tag = 'ResetView';
uimenu(props);

% Limit/Camera options
props.Label = getString(message('MATLAB:uistring:interaction:LimitsPanandZoom'));
props.Separator = 'on';
props.Tag = 'limits';
lim = uimenu(props);

props.Label = getString(message('MATLAB:uistring:interaction:CameraPanandZoom'));
props.Tag = 'camera';
props.Separator = 'off';
cam = uimenu(props);

% 2D submenu
props.Callback = {@localUIContextMenuCallback,hMode};
props.Label = getString(message('MATLAB:uistring:zoom:UnconstrainedZoom'));
props.Tag = 'ZoomUnconstrained2D';
props.Separator = 'on';
h2D(1) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:HorizontalZoom'));
props.Tag = 'ZoomHorizontal';
props.Separator = 'off';
h2D(2) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:VerticalZoom'));
props.Tag = 'ZoomVertical';
h2D(3) = uimenu(props);
localUIContextMenuUpdate2DConstraint(hMode,hMode.ModeStateData.Constraint);

% 3D submenu
props.Callback = {@loc3DUIContextMenuCallback,hMode};
props.Label = getString(message('MATLAB:uistring:zoom:UnconstrainedZoom'));
props.Tag = 'unconstrained';
props.Separator = 'on';
h3D(1) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:XZoom'));
props.Tag = 'x';
props.Separator = 'off';
h3D(2) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:YZoom'));
props.Tag = 'y';
h3D(3) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:ZZoom'));
props.Tag = 'z';
h3D(4) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:XYZoom'));
props.Tag = 'xy';
h3D(5) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:YZZoom'));
props.Tag = 'yz';
h3D(6) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:zoom:XZZoom'));
props.Tag = 'xz';
h3D(7) = uimenu(props);

hui.addprop('Camera');
hui.Camera = cam;
hui.addprop('Limits');
hui.Limits = lim;
hui.addprop('Constraints2D');
hui.Constraints2D = h2D;
hui.addprop('Constraints3D');
hui.Constraints3D = h3D;
hui.addprop('ZoomOut');
hui.ZoomOut = zoomout;

%-----------------------------------------------%
function localGetContextMenu(hMode)
% Create context menu

hui = get(hMode,'UIContextMenu');

if isempty(hui) || ~ishghandle(hui)
    hui = localUICreateDefaultContextMenu(hMode);
    set(hMode,'UIContextMenu',hui);
end
if isempty(hMode.ModeStateData.CustomContextMenu) || ~ishghandle(hMode.ModeStateData.CustomContextMenu)
    localUIUpdateContextMenuLabel(hui.ZoomOut,hMode.ModeStateData.Direction);
end

%-------------------------------------------------%
function localUIContextMenuCallback(obj,~,hMode)
import matlab.graphics.interaction.internal.*
tag = get(obj,'tag');
allAxes = hMode.FigureState.CurrentAxes;
hAxes = validateAxes(allAxes,'Zoom');
        
switch(tag)
    case 'ZoomInOut'
        % If we are here, then we clicked on something contained in an
        % axes. Rather than calling HITTEST, we will get this information
        % manually.
        arrayfun(@(x)(localStoreLimits(x)),hAxes);
        zoom_factor = localGetZoomFactor(hMode.ModeStateData.Direction);
        hMode.fireActionPreCallback(localConstructEvd(hAxes));
        localApplyZoomFactor(hMode,hAxes,1/zoom_factor,false);

    case 'ResetView'
        % If we are here, then we clicked on something contained in an
        % axes. Rather than calling HITTEST, we will get this information
        % manually.
        hMode.fireActionPreCallback(localConstructEvd(hAxes));
        resetplotview(hAxes,'ApplyStoredView');
        hMode.fireActionPostCallback(localConstructEvd(hAxes));
    case 'ZoomContextMenu'
        if is2D(hAxes(1))
            localUIContextMenuUpdate2DConstraint(hMode,hMode.ModeStateData.Constraint);
            set(obj.Constraints2D,'Visible','on');
            set(obj.Constraints3D,'Visible','off');
            set(obj.Camera,'Visible','off');
            set(obj.Limits,'Visible','off');
        else
            hFig = hMode.FigureHandle;
            updateUIContextMenu3DVersion(hFig,'none',hAxes);
            updateUIContextMenu3DConstraint(hFig,hAxes,'default');
            set(obj.Camera,'Visible','on');
            set(obj.Limits,'Visible','on');
            set(obj.Constraints2D,'Visible','off');
            if strcmp(obj.Camera.Checked,'on')
                set(obj.Constraints3D,'Visible','off');
            else
                set(obj.Constraints3D,'Visible','on');
            end 
        end
    % 2D specific
    case 'ZoomUnconstrained2D'
        localUIContextMenuUpdate2DConstraint(hMode,'none');
    case 'ZoomHorizontal'
        localUIContextMenuUpdate2DConstraint(hMode,'horizontal');
    case 'ZoomVertical'
        localUIContextMenuUpdate2DConstraint(hMode,'vertical');
    % 3D specific
    case 'limits'
        updateUIContextMenu3DVersion(hMode.FigureHandle,'limits',hAxes);
    case 'camera'
        updateUIContextMenu3DVersion(hMode.FigureHandle,'camera',hAxes);
end

%-----------------------------------------------%
function localUIUpdateContextMenuLabel(zoomout, zoom_direction)
if strcmp(zoom_direction,'in')
    set(zoomout,'Label',getString(message('MATLAB:uistring:zoom:ZoomOutShiftClick')));
else
    set(zoomout,'Label',getString(message('MATLAB:uistring:zoom:ZoomInShiftClick')));
end

%-------------------------------------------------%
function loc3DUIContextMenuCallback(obj,~,hMode)

tag = get(obj,'tag');

allAxes = hMode.FigureState.CurrentAxes;
hAxes = matlab.graphics.interaction.internal.validateAxes(allAxes,'Zoom');

updateUIContextMenu3DConstraint(hMode.FigureHandle,hAxes,tag);

%-------------------------------------------------%
function updateUIContextMenu3DConstraint(hFigure,hAxes,cons)
consStrings = {'x','y','z','xy','yz','xz','unconstrained'};
for i = 1:numel(consStrings)
    consMenus(i) = findall(hFigure,'Tag',consStrings{i},'Type','UIMenu'); %#ok<AGROW>
end

if ~strcmp(cons,'default')
    setZoomConstraint(hAxes,cons);
else
    % for a new contextmenu, use the behavior object to determine which menu
    % item should be checked
    cons = getZoomBehaviorConstraint(hAxes);
    if isempty(cons)
        cons = 'unconstrained';
    end 
end

for i = 1:numel(consMenus)
    if strcmp(cons,consMenus(i).Tag)
        consMenus(i).Checked = 'on';
    else
        consMenus(i).Checked = 'off';
    end
end

%-------------------------------------------------%
function cons = getZoomBehaviorConstraint(hAxes)

localBehavior = hggetbehavior(hAxes(1),'Zoom','-peek');
if ~isempty(localBehavior)
    cons = localBehavior.Constraint3D;
else
    cons = [];
end

%-------------------------------------------------%
function cons = setZoomConstraint(hAxes, cons)

localBehavior = hggetbehavior(hAxes,'Zoom');
localBehavior.Constraint3D = cons;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%-------Broadcasting Mode Changes -------%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------%
function localUIContextMenuUpdate2DConstraint(hMode,zoom_Constraint)

hFigure = get(hMode,'FigureHandle');
uimenus = findall(hFigure,'Type','UIMenu');
ux = findall(uimenus,'Tag','ZoomHorizontal');
uy = findall(uimenus,'Tag','ZoomVertical');
uxy = findall(uimenus,'Tag','ZoomUnconstrained2D');

localChangeConstraint(hMode,zoom_Constraint)

switch(lower(zoom_Constraint))

    case 'none'
        set(ux,'Checked','off');
        set(uy,'Checked','off');
        set(uxy,'Checked','on');

    case 'horizontal'
        set(ux,'Checked','on');
        set(uy,'Checked','off');
        set(uxy,'Checked','off');

    case 'vertical'
        set(ux,'Checked','off');
        set(uy,'Checked','on');
        set(uxy,'Checked','off');
end

% This function is identical to the one found in schema.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomIn(hMode)
 
set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','on');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomOut','ToolbarZoomOutButton'),'State','off');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomX','ToolbarZoomXButton'),'State','off');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomY','ToolbarZoomYButton'),'State','off');
set(uifindallFromModeCache(hMode,'figMenuZoomIn','MenuZoomIn'),'Checked', 'on');
set(uifindallFromModeCache(hMode,'figMenuZoomOut','MenuZoomOut'),'Checked', 'off');

function [hZoomX,hZoomY] = localGetConstrainedZoomToolbarButtons(hMode)

hZoomX = uigettoolFromModeCache(hMode,'Exploration.ZoomX','ToolbarZoomXButton');
hZoomY = uigettoolFromModeCache(hMode,'Exploration.ZoomY','ToolbarZoomYButton');

% This function is identical to the one found in schema.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomInX(hMode)

set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','off');
[hZoomX,hZoomY] = localGetConstrainedZoomToolbarButtons(hMode);
% If there is no X button, this is the same as in mode:
if isempty(hZoomX)   
    set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','on');
    set(uigettoolFromModeCache(hMode,'Exploration.ZoomOut','ToolbarZoomOutButton'),'State','off');
else
    set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','off');
    set(uigettoolFromModeCache(hMode,'Exploration.ZooOut','ToolbarZoomOutButton'),'State','off');
    set(hZoomX,'State','on');
    set(hZoomY,'State','off');
end
set(uifindallFromModeCache(hMode,'figMenuZoomIn','MenuZoomIn'), 'Checked', 'on');
set(uifindallFromModeCache(hMode,'figMenuZoomOut','MenuZoomOut'),'Checked', 'off');

% This function is identical to the one found in schema.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomInY(hMode)

set(uigettoolFromModeCache(hMode,'Exploration.ZoomOut','ToolbarZoomOutButton'),'State','off');
[hZoomX,hZoomY] = localGetConstrainedZoomToolbarButtons(hMode);
% If there is no Y button, this is the same as in mode:
if isempty(hZoomY)
    set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','on');
    set(uigettoolFromModeCache(hMode,'Exploration.ZoomOut','ToolbarZoomOutButton'),'State','off');
else
    set(uigettoolFromModeCache(hMode,'Exploration.ZoomOut','ToolbarZoomOutButton'),'State','off');
    set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','off');
    set(hZoomY,'State','on');
    set(hZoomX,'State','off');
end
set(uifindallFromModeCache(hMode,'figMenuZoomIn','MenuZoomIn'), 'Checked', 'on');
set(uifindallFromModeCache(hMode,'figMenuZoomOut','MenuZoomOut'),'Checked', 'off');

% This function is identical to the one found in schema.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomOut(hMode)

% Protect against cached buttons/menus being removed after the mode
% was activated. This is most likely to happen when a menubar or toolbar
% has been deleted.
    
set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','off');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomOut','ToolbarZoomOutButton'),'State','on');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomX','ToolbarZoomXButton'),'State','off');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomY','ToolbarZoomYButton'),'State','off');
set(uifindallFromModeCache(hMode,'figMenuZoomIn','MenuZoomIn'), 'Checked', 'off');
set(uifindallFromModeCache(hMode,'figMenuZoomOut','MenuZoomOut'),'Checked', 'on');
%-----------------------------------------------%
function localUISetZoomOff(hMode)

% Protect against cached buttons/menus being removed after the mode
% was activated. This is most likely to happen when a menubar or toolbar
% has been deleted.

set(uigettoolFromModeCache(hMode,'Exploration.ZoomIn','ToolbarZoomInButton'),'State','off');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomOut','ToolbarZoomOutButton'),'State','off');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomX','ToolbarZoomXButton'),'State','off');
set(uigettoolFromModeCache(hMode,'Exploration.ZoomY','ToolbarZoomYButton'),'State','off');
set(uifindallFromModeCache(hMode,'figMenuZoomIn','MenuZoomIn'), 'Checked', 'off');
set(uifindallFromModeCache(hMode,'figMenuZoomOut','MenuZoomOut'),'Checked', 'off');

%-----------------------------------------------%
function result = lessThan(ruler, a, b)
if ~isempty(ruler)
    anum = ruler2num(a,ruler);
    bnum = ruler2num(b,ruler);
else
    anum = a;
    bnum = b;
end
result = anum < bnum;
