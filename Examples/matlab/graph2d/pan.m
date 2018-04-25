function [out] = pan(arg1,arg2)
%PAN Interactively pan the view of a plot
%  PAN ON turns on mouse-based panning.
%  PAN XON turns on x-only panning
%  PAN YON turns on y-only panning
%  PAN OFF turns it off.
%  PAN by itself toggles the state.
%
%  PAN(FIG,...) works on specified figure handle.
%
%  H = PAN(FIG) returns the figure's pan mode object for customization.
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
%        Set this callback to listen to when a pan operation will start.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object.
%
%             The event object has the following read only 
%             property:
%             Axes             The handle of the axes that is being panned.
%
%        ActionPostCallback <function_handle>
%        Set this callback to listen to when a pan operation has finished.
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
%        The type of panning for the figure.
%
%        UIContextMenu <handle>
%        Specifies a custom context menu to be displayed during a
%        right-click action.
%
%  FLAGS = isAllowAxesPan(H,AXES)
%       Calling the function ISALLOWAXESPAN on the pan object, H, with a
%       vector of axes handles, AXES, as input will return a logical array
%       of the same dimension as the axes handle vector which indicate
%       whether a pan operation is permitted on the axes objects.
%
%  setAllowAxesPan(H,AXES,FLAG)
%       Calling the function SETALLOWAXESPAN on the pan object, H, with
%       a vector of axes handles, AXES, and a logical scalar, FLAG, will
%       either allow or disallow a pan operation on the axes objects.
%
%  INFO = getAxesPanMotion(H,AXES)
%       Calling the function GETAXESPANMOTION on the pan object, H, with 
%       a vector of axes handles, AXES, as input will return a character
%       cell array of the same dimension as the axes handle vector which
%       indicates the type of pan operation for each axes. Possible values
%       for the type of operation are 'horizontal', 'vertical' or 'both'.
%
%  setAxesPanMotion(H,AXES,STYLE)
%       Calling the function SETAXESPANMOTION on the pan object, H, with a
%       vector of axes handles, AXES, and a character array, STYLE, will
%       set the style of panning on each axes.
%
%  EXAMPLE 1:
%
%  plot(1:10);
%  pan on
%  % pan on the plot
%
%  EXAMPLE 2:
%
%  plot(1:10);
%  h = pan;
%  h.Motion = 'horizontal';
%  h.Enable = 'on';
%  % pan on the plot in the horizontal direction.
%
%  EXAMPLE 3:
%
%  ax1 = subplot(2,2,1);
%  plot(1:10);
%  h = pan;
%  ax2 = subplot(2,2,2);
%  plot(rand(3));
%  setAllowAxesPan(h,ax2,false);
%  ax3 = subplot(2,2,3);
%  plot(peaks);
%  setAxesPanMotion(h,ax3,'horizontal');
%  ax4 = subplot(2,2,4);
%  contour(peaks);
%  setAxesPanMotion(h,ax4,'vertical');
%  % pan on the plots.
%
%  EXAMPLE 4: (copy into a file)
%      
%  function demo
%  % Allow a line to have its own 'ButtonDownFcn' callback.
%  hLine = plot(rand(1,10));
%  hLine.ButtonDownFcn = 'disp(''This executes'')';
%  hLine.Tag = 'DoNotIgnore';
%  h = pan;
%  h.ButtonDownFilter = @mycallback;
%  h.Enable = 'on';
%  % mouse click on the line
%
%  function [flag] = mycallback(obj,event_obj)
%  % If the tag of the object is 'DoNotIgnore', then return true.
%  objTag = obj.Tag;
%  if strcmpi(objTag,'DoNotIgnore')
%     flag = true;
%  else
%     flag = false;
%  end
%
%   EXAMPLE 5: (copy into a file)
%
%   function demo
%   % Listen to pan events
%   plot(1:10);
%   h = pan;
%   h.ActionPreCallback = @myprecallback;
%   h.ActionPostCallback = @mypostcallback);
%   h.Enable = 'on';
%
%   function myprecallback(obj,evd)
%   disp('A pan is about to occur.');
%
%   function mypostcallback(obj,evd)
%   newLim = evd.Axes.XLim;
%   msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim));
%
%  Use LINKAXES to link panning across multiple axes.
%
%  See also ZOOM, ROTATE3D, LINKAXES.

% Copyright 2002-2017 The MathWorks, Inc.

% Undocumented syntax
%  PAN(FIG,STYLE); where STYLE = 'x'|'y'|'xy', Note: syntax doesn't turn pan on like 'xon'
%  OUT = PAN(FIG,'getstyle')  'x'|'y'|'xy'
%  OUT = PAN(FIG,'ison')  true/false
%  PAN(FIG,'onkeepstyle'); maintains the last style used by pan mode. Used by
%  the GUI.

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

if nargin==0
    fig = gcf; % caller did not specify handle
    matlab.ui.internal.UnsupportedInUifigure(fig);
    if nargout == 0
        locSetState(fig,'toggle');
    else
        out = locGetObj(fig);
    end
elseif nargin==1
    if ishghandle(arg1)
        matlab.ui.internal.UnsupportedInUifigure(arg1);
        if nargout == 0
            locSetState(arg1,'toggle');
        else
            out = locGetObj(arg1);
        end
    else
        if nargout > 0 % nargout is not valid in this case;
            error(message('MATLAB:pan:InvalidInputForOutArg'));
        else
            fig = gcf; % caller did not specify handle
            matlab.ui.internal.UnsupportedInUifigure(fig);
            locSetState(fig,arg1);
        end
    end
elseif nargin==2
    if ~ishghandle(arg1)
        error(message('MATLAB:pan:FigureUnknown'));
    end
    if ~matlab.uitools.internal.uimode.isLiveEditorFigure(arg1)
        matlab.ui.internal.UnsupportedInUifigure(arg1);
    end
    switch arg2
        case 'getstyle'
            out = locGetStyle(arg1);
        case 'ison'
            out = locIsOn(arg1);
        otherwise
            if nargout > 0
                error(message('MATLAB:pan:InvalidInputForOutArg'));
            else
                locSetState(arg1,arg2);
            end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%----------- Helper Functions for External API----------%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function hPan = locGetObj(hFig)
% Return the pan accessor object, if it exists.
hMode = locGetMode(hFig);
if ~isfield(hMode.ModeStateData,'accessor') ||...
        ~ishandle(hMode.ModeStateData.accessor)
    % Call the appropriate mode accessor
    hPan = matlab.graphics.interaction.internal.pan(hMode);
    hMode.ModeStateData.accessor = hPan;
else
    hPan = hMode.ModeStateData.accessor;
end

%-----------------------------------------------%
function [out] = locIsOn(fig)

out = isactiveuimode(fig,'Exploration.Pan');

%-----------------------------------------------%
function [out] = locGetStyle(fig)

hMode = locGetMode(fig);
out = hMode.ModeStateData.style;

%-----------------------------------------------%
function locSetState(target,state)
%Enables/disables panning callbacks
% target = figure || axes
% state = 'on' || 'off'

fig = ancestor(target,'figure');
hMode = locGetMode(fig);

switch(state)
    case 'xon'
        state = 'on';
        hMode.ModeStateData.style = 'x';
    case 'yon'
        state = 'on';
        hMode.ModeStateData.style = 'y';
    case 'x'
        hMode.ModeStateData.style = 'x';
        return; % All done
    case 'y'
        hMode.ModeStateData.style = 'y';
        return; % All done
    case 'xy'
        hMode.ModeStateData.style = 'xy';
        return; % All done
    case 'on'
        hMode.ModeStateData.style = 'xy';
    case 'onkeepstyle'
        state = 'on';
    case 'toggle'
        if locIsOn(fig)
            state = 'off';
        else
            state = 'on';
        end
end

if strcmpi(state,'on')
    activateuimode(fig,hMode.Name);
elseif strcmpi(state,'off')
    if locIsOn(fig)
        activateuimode(fig,'');
    end
else
    error(message('MATLAB:pan:unrecognizedinput'));
end

%-----------------------------------------------%
function [hMode] = locGetMode(hFig)
hMode = getuimode(hFig,'Exploration.Pan');
if isempty(hMode)
    %Construct the mode object and set properties
    hMode = uimode(hFig,'Exploration.Pan');
    set(hMode,'WindowButtonDownFcn',@(obj,evd)locWindowButtonDownFcn(obj,evd,hMode));
    set(hMode,'WindowButtonMotionFcn',@(obj,evd)locWindowButtonMotionFcn(obj,evd,hMode));
    set(hMode,'KeyPressFcn',@(obj,evd)locKeyPressFcn(obj,evd,hMode));
    set(hMode,'ModeStartFcn',@(~,~)locDoPanOn(hMode));
    set(hMode,'ModeStopFcn',@(~,~)locDoPanOff(hMode));
    hMode.ModeStateData.style = 'xy';
    hMode.ModeStateData.mouse = 'off';
    hMode.ModeStateData.ToolbarButton = uigettool(hMode.FigureHandle,'Exploration.Pan');
    hMode.ModeStateData.MenuItem = findall(hMode.FigureHandle,'tag','figMenuPan');
    hMode.ModeStateData.CustomContextMenu = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%----------- 2D/3D Shared Callbacks----------%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function locWindowButtonUpFcn(~,~,ax,hMode,buttonDownData)
import matlab.graphics.interaction.*

hfig = hMode.FigureHandle;

set(hMode,'WindowButtonMotionFcn',@(obj,evd)locWindowButtonMotionFcn(obj,evd,hMode));
set(hMode,'WindowButtonUpFcn',[]);

hMode.fireActionPostCallback(localConstructEvd(ax));

% Axes may be empty if we are double clicking
if ~isempty(ax) && ishghandle(ax(1))
    if isscalar(ax)
        % if axes limit pan (2D or 3D)
        if buttonDownData.is2D || buttonDownData.isLimitPanAndZoom
            % Use datatyped limits with given datatypes for undo/redo
            origlim = buttonDownData.orig_axlim;
            newlim = getDoubleAxesLimits(ax);
            if ~isequal(newlim,origlim)
                origlimdatatyped = buttonDownData.orig_axlim_datatyped;
                newlimdatatyped = getAxesLimits(ax);
                locCreateLimitUndo(ax,{origlimdatatyped},newlimdatatyped);
                
                if strcmp(hMode.ModeStateData.mouse,'dragging')
                    localThrowEndDragEvent(ax(1));
                end
            elseif buttonDownData.is2D && ~isempty(buttonDownData(1).OrigYYAxisYLimMode)
                % If we did not pan, put inactive side of yyaxis back to
                % original state
                internal.setYYAxisInactiveYLimMode(ax(1),buttonDownData.OrigYYAxisYLimMode);
            end
        else  % camera pan
            newtar = {ax.CameraTarget};
            newpos = {ax.CameraPosition};
            origtar = {buttonDownData.orig_target};
            origpos = {buttonDownData.orig_pos};
            if ~isequal(newtar,origtar) || ~isequal(newpos,origpos)
                locCreate3DCameraUndo(ax,origtar,newtar,origpos,newpos);
                localThrowEndDragEvent(ax);
            end
        end
    else
        % Assumption for plotyy plots - If we pan one axes, we pan both
        % axes.
        % Use datatyped limits with given datatypes for undo/redo
        origlim = buttonDownData(1).orig_axlim;
        newlim = getDoubleAxesLimits(ax(1));
        if ~isequal(newlim,origlim)
            for i = 1:numel(buttonDownData)
                origlimdatatyped{i} = buttonDownData(i).orig_axlim_datatyped; %#ok<AGROW>
            end
            newlimdatatyped = getAxesLimits(ax);
            locCreateLimitUndo(ax,origlimdatatyped,newlimdatatyped);
            
            if strcmp(hMode.ModeStateData.mouse,'dragging')
                localThrowEndDragEvent(ax(1));
            end
        end
    end

    % Turn back on axes dirty listeners to dirty the legend when an axes
    % property changes
    internal.toggleAxesLayoutManager(hfig,ax,true);
end

% Clear all transient pan state
hMode.ModeStateData.mouse = 'off';

%-----------------------------------------------%
function locWindowButtonMotionFcn(obj,evd, hMode)
import matlab.graphics.interaction.internal.*
% This gets called every time we move the mouse in pan mode,
% regardless of whether any buttons are pressed.
fig = hMode.FigureHandle;

% Get current point in pixel units
[hAx, ~, rulere] = locFindAxes(obj,evd);
newcursor = 'arrow';
if ~isempty(hAx)
    cons = getConstraint(hAx(1), getPanBehaviorConstraint(hAx(1)), hMode.ModeStateData.style);
    [en, style] = pan.isPanEnabled(hAx(1), cons, rulere);
    if en
        cursor = constraintToCursorName(hAx(1),style);
        newcursor = cursor;
    end
end
setPointer(fig,newcursor);

%-----------------------------------------------%
function cursor = constraintToCursorName(ax,cons)
if is2D(ax)
    cons = matlab.graphics.interaction.internal.constraintConvert3DTo2D(cons);
end
cursor = ['pan_' cons];

%-----------------------------------------------%
function locPanWindowMotionFcn(fig, evd, ax, hMode, buttonData)
curr_pixel = getPointInPixels(fig,evd.Point);

localThrowBeginDragEvent(ax(1));
hMode.ModeStateData.mouse = 'dragging';

for i = 1:numel(ax)
    buttonData(i).currPixel = curr_pixel;
    locDataPan(ax(i),buttonData(i));
end

%-----------------------------------------------%
function locWindowButtonDownFcn(~,evd,hMode)
import matlab.graphics.interaction.*
% Begin panning
if ~ishghandle(hMode.UIContextMenu)
    %We lost the context menu for some reason
    locUICreateDefaultContextMenu(hMode);
end
fig = hMode.FigureHandle;
[ax, ruler, rulerenum] = locFindAxes(fig,evd);

if ~isempty(ax) && ishghandle(ax(1))
    cons = getConstraint(ax(1),getPanBehaviorConstraint(ax(1)), hMode.ModeStateData.style);
    [enabled, constraint] = internal.pan.isPanEnabled(ax(1), cons, rulerenum);
else
    enabled = false;
end

sel_type = lower(get(fig,'SelectionType'));
if ~enabled
    if strcmp(sel_type,'alt')
        hMode.ShowContextMenu = false;
    end
    return;
end

if ~isempty(ruler)
    hMode.ShowContextMenu = false;
end

% Register view with axes for "Reset to Original View" support
internal.initializeView(ax);

switch sel_type
    case 'normal' % left click
		point = getPointInPixels(fig,evd.Point);
        for i = 1:numel(ax)
            buttonDownData(i) = createButtonDownEventData(fig, ax(i), constraint, point, ruler, rulerenum); %#ok<AGROW>
        end
        
        % set global state
        hMode.ModeStateData.mouse = 'down';
        hMode.fireActionPreCallback(localConstructEvd(ax));

        % Turn off axes dirty listeners for performance when a legend is
        % present
        internal.toggleAxesLayoutManager(fig,ax,false);
        
        set(hMode, 'WindowButtonMotionFcn', @(~,e)locPanWindowMotionFcn(fig, e, ax, hMode, buttonDownData));
        set(hMode, 'WindowButtonUpFcn', @(~,e)locWindowButtonUpFcn(fig,e,ax,hMode,buttonDownData));

    case 'open' % double click (left or right)
        % Don't need preActionCallback since it was fired on the first
        % button down of the double click
        locReturnHome(ax);
        hMode.fireActionPostCallback(localConstructEvd(ax));
        hMode.ModeStateData.mouse = 'off';
    case 'alt' % right click
        localGetContextMenu(hMode);
    case 'extend' % center click
        % do nothing
end

function localGetContextMenu(hMode)
%Create context menu
hui = get(hMode,'UIContextMenu');

if isempty(hui) || ~ishghandle(hui)
    hui = locUICreateDefaultContextMenu(hMode);
    set(hMode,'UIContextMenu',hui);
end
    
%-----------------------------------------------%
function locDataPan(ax,pressData)
% This is where the panning computation occurs.
import matlab.graphics.interaction.*

% Assumption - If the first plotyy axes is 2D, then all plotyy axes are 2D.
if pressData.is2D
    orig_ds = pressData.dataspace;
    orig_trans_limits = [0,1,0,1,0,1];
    pixel_diff = pressData.currPixel-pressData.origPixel;
    ruler_lengths =  pressData.plotBox;
    
    % abort if we are equal to bounds
    orig_limits = pressData.orig_axlim; 
    bound_limits = pressData.imageBounds;
    if pressData.hasImage && all((bound_limits(1:4) == orig_limits(1:4)))
        return;
    end
    
    new_trans_limits = internal.pan.panFromPixelToPixel2D(orig_trans_limits,pixel_diff,ruler_lengths);
    
    if pressData.hasImage % Determine axis limits for image
        bound_limits = pressData.transImageBounds;
        %If we are within the bounds of the image to begin with. This is to
        %prevent odd behavior if we panned outside the bounds of the image
        tolerance = 1e-4;
        if bound_limits(1) <= (orig_trans_limits(1)+tolerance) && (bound_limits(2)+tolerance) >= orig_trans_limits(2) &&...
           bound_limits(3) <= (orig_trans_limits(3)+tolerance) && (bound_limits(4)+tolerance) >= orig_trans_limits(4)

            new_trans_limits(1:2) = internal.boundLimits(new_trans_limits(1:2), bound_limits(1:2), true);
            new_trans_limits(3:4) = internal.boundLimits(new_trans_limits(3:4), bound_limits(3:4), true);
        end
    end
    

    if pressData.isRulerHit
        new_trans_limits = constrain_lims(new_trans_limits, orig_limits(1:4), pressData.rulerenum);
    end

    [xl, yl] = internal.UntransformLimits(orig_ds,new_trans_limits(1:2),new_trans_limits(3:4),[0,1]);
    
    % Revert limits if we are constrained
    if strcmp(pressData.style,'x')
        yl = orig_limits(3:4);
    elseif strcmp(pressData.style,'y')
        xl = orig_limits(1:2);
    end    
    
    validateAndSetLimits(ax, xl, yl);
    drawnow update;
elseif pressData.isLimitPanAndZoom % 3D limit pan
    % unbundle event data from buttondown
    orig_limits = [0,1,0,1,0,1];
    curr_pixel = pressData.currPixel;
    tform = pressData.transform;
    orig_ray = pressData.origRay;
    orig_ds = pressData.dataspace;
    
    % find "current ray" given pixel values 
    curr_ray = internal.pan.transformPixelsToPoint(tform,curr_pixel);
    
    if pressData.unconstrainedPan  % unconstrained
        trans_limits = internal.pan.panFromPointToPoint3D(orig_limits,orig_ray,curr_ray);
    elseif pressData.axisPan  % x, y or z
        planenum = pressData.planenum;
        trans_limits = constrainedAxisPan(pressData.rulerNum,planenum,orig_limits,orig_ray,curr_ray);
    elseif pressData.planePan % xy, yz, or xz
        normal = pressData.normal;
        trans_limits = constrainedPlanePan(orig_limits,normal,orig_ray,curr_ray);
    end

    [xl, yl, zl] = internal.UntransformLimits(orig_ds,trans_limits(1:2),trans_limits(3:4),trans_limits(5:6));
    validateAndSetLimits(ax, xl, yl, zl);
else % 3D camera pan
    % Force ax to be in vis3d to avoid wacky resizing
    axis(ax,'vis3d');
    delta = pressData.currPixel-pressData.origPixel;  
    if ~righthanded(ax), delta(1) = -delta(1); end
    axpos = getpixelposition(ax);
    
    [newcp, newct] = camdollyGivenData(axpos, -delta(1),-delta(2), pressData.orig_dar, pressData.orig_pos, pressData.orig_target, pressData.orig_up, pressData.orig_va);
    
    if all(isfinite(newcp))
        ax.CameraUpVectorMode = 'manual';
        ax.CameraPosition = newcp;
    end
    
    if all(isfinite(newct))
        ax.CameraTarget = newct;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%----------- Create EventData----------%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------%
function buttonDownData = createButtonDownEventData(fig, ax, constraint, point, ruler, rulere)
% creates eventdata needed by WindowButtonMotionFcn, WindowButtonDownFcn,
% and WindowKeyPressFcn
import matlab.graphics.interaction.*

buttonDownData = [];   

buttonDownData.isRulerHit = ~isempty(ruler);
if buttonDownData.isRulerHit
    buttonDownData.ruler = ruler;
    buttonDownData.rulerenum = rulere;
    buttonDownData.style = rulere;
    
    buttonDownData.axisPan = true;
    buttonDownData.planePan = false;
    buttonDownData.unconstrainedPan = false;
end

buttonDownData.origPixel = point;
buttonDownData.style = constraint;

if is2D(ax)
    buttonDownData.is2D = true;
    buttonDownData.plotBox = ax.GetLayoutInformation.PlotBox(3:4);
    buttonDownData.dataspace = internal.copyDataSpace(ax.ActiveDataSpace);
    buttonDownData.orig_axlim = getDoubleAxesLimits(ax);
    ax_lims = getAxesLimits(ax);
    buttonDownData.orig_axlim_datatyped = ax_lims{1};
    buttonDownData.OrigYYAxisYLimMode = internal.setYYAxisInactiveYLimMode(ax,'manual');
    
    buttonDownData.transImageBounds = nan(6,1);
    buttonDownData.imageBounds = nan(6,1);
    if ~isempty(findobj(ax,'Type','image'))
        lims = getGraphicsExtents(ax);
        buttonDownData.hasImage = true;
        [imageboundsx,imageboundsy] = internal.TransformLimits(ax.ActiveDataSpace,lims(1:2),lims(3:4),[0,1]);
        buttonDownData.transImageBounds = [imageboundsx,imageboundsy];
        buttonDownData.imageBounds = lims;
    else
        buttonDownData.hasImage = false;
    end
else
    ax = ax(1);  % in 3D, we will only pan one axes at a time
    buttonDownData.is2D = false;
    buttonDownData.isLimitPanAndZoom = strcmp(internal.getAxes3DPanAndZoomStyle(fig,ax(1)),'limits');

    % 3D clipping pan
    if buttonDownData.isLimitPanAndZoom
        % To avoid strange behavior, change CameraTarget and CameraViewAngle back to auto
        ax.CameraTargetMode = 'auto';
        ax.CameraPositionMode = 'auto';
        drawnow;
        
        if ~buttonDownData.isRulerHit
            switch(buttonDownData.style)
                case {'x','y','z'}
                    buttonDownData.axisPan = true;
                    buttonDownData.planePan = false;
                    buttonDownData.unconstrainedPan = false;
                case {'xy','yz','xz'}
                    buttonDownData.axisPan = false;
                    buttonDownData.planePan = true;
                    buttonDownData.unconstrainedPan = false;
                otherwise
                    buttonDownData.axisPan = false;
                    buttonDownData.planePan = true;
                    buttonDownData.unconstrainedPan = true;
            end
        end

        buttonDownData.transform = internal.pan.getMVP(ax);
        buttonDownData.origRay = internal.pan.transformPixelsToPoint(buttonDownData.transform,point);
        buttonDownData.dataspace = internal.copyDataSpace(ax.ActiveDataSpace);
        
        % Store original axis limits
        buttonDownData.orig_axlim_datatyped = getAxesLimits(ax);
        buttonDownData.orig_axlim_datatyped = buttonDownData.orig_axlim_datatyped{1};
        buttonDownData.orig_axlim = getDoubleAxesLimits(ax);

        buttonDownData = addAxisEventData(buttonDownData,point);
        buttonDownData = addPlaneEventData(buttonDownData);
    % 3D camera pan
    else
        % Store the original camera position and target
        buttonDownData.orig_target = ax.CameraTarget;
        buttonDownData.orig_pos = ax.CameraPosition;
        buttonDownData.orig_up = ax.CameraUpVector;
        buttonDownData.orig_va = ax.CameraViewAngle;
        buttonDownData.orig_dar = ax.DataAspectRatio;
    end
end

%-------------------------------------------------%
function buttonDownData = addAxisEventData(buttonDownData,point)
import matlab.graphics.interaction.internal.pan.*
if ~buttonDownData.is2D && buttonDownData.isLimitPanAndZoom && buttonDownData.axisPan
    test_ray = transformPixelsToPoint(buttonDownData.transform,point+[10,10]);    
    switch(buttonDownData.style)
        case 'x'
            buttonDownData.rulerNum = 1;
        case 'y'
            buttonDownData.rulerNum = 2;
        case 'z'
            buttonDownData.rulerNum = 3;
    end
           
    % For x, project points onto y plane
    % For y, project points onto z plane
    % For z, project points onto x plane
    normal1 = zeros(3,1);
    normal1(mod(buttonDownData.rulerNum,3)+1) = 1;
    
    % For x, project points onto z plane
    % For y, project points onto x plane
    % For z, project points onto y plane
    normal2 = zeros(3,1);
    normal2(mod(buttonDownData.rulerNum+1,3)+1) = 1;
    d1 = findProjectedVectorOnPlane(buttonDownData.origRay, test_ray, normal1);
    d2 = findProjectedVectorOnPlane(buttonDownData.origRay, test_ray, normal2);

    % Figure out the best plane to project onto
    buttonDownData.planenum = 1;
    if all(isfinite(d1)) && all(isfinite(d2)) && d2(buttonDownData.rulerNum)>d1(buttonDownData.rulerNum)
        buttonDownData.planenum = 2;
    elseif ~all(isfinite(d1))
        buttonDownData.planenum = 2;        
    end
end

%-------------------------------------------------%
function buttonDownData = addPlaneEventData(buttonDownData)
if buttonDownData.planePan
    switch(buttonDownData.style)
        case 'xy'
            buttonDownData.normal = [0,0,1];
        case 'yz'
            buttonDownData.normal = [1,0,0];
        case 'xz'
            buttonDownData.normal = [0,1,0];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%----------- 2D/3D Shared Helper Code----------%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function locReturnHome(ax)
% Fit plot to axes
origlimdatatyped = matlab.graphics.interaction.getAxesLimits(ax);
resetplotview(ax,'ApplyStoredView');
newlimdatatyped = matlab.graphics.interaction.getAxesLimits(ax);
locCreateLimitUndo(ax,origlimdatatyped,newlimdatatyped);

%-------------------------------------------------%
function new_pt = getPointInPixels(hFig,old_pt)
% eventdata information is always in pixels, so we must convert
if ~strcmpi(hFig.Units,'Pixels')
    ptrect = hgconvertunits(hFig, [0,0,old_pt], hFig.Units, 'Pixels', hFig);
    new_pt = ptrect(3:4);
else
    new_pt = old_pt;
end

%-----------------------------------------------%
function evd = localConstructEvd(hAxes)
% Construct event data for post callback
evd.Axes = hAxes;

%-------------------------------------------------%
function localThrowBeginDragEvent(hObj)

% Throw BeginDrag event
hb = hggetbehavior(hObj,'Pan','-peek');
if ~isempty(hb) && (ishandle(hb) || isobject(hb))
    sendBeginDragEvent(hb);
end

%-------------------------------------------------%
function localThrowEndDragEvent(hObj)

% Throw EndDrag event
hb = hggetbehavior(hObj,'Pan','-peek');
if ~isempty(hb) && (ishandle(hb) || isobject(hb))
    sendEndDragEvent(hb);
end

%-----------------------------------------------%
function [ax, ruler, renum] = locFindAxes(fig,evd)
% Return the axes that the mouse is currently over
% Return empty if no axes found (i.e. axes has hidden handle)
import matlab.graphics.interaction.*

if ~ishghandle(fig)
    return;
end

% Return all axes under the current mouse point
ax = internal.hitAxes(fig, evd);
ruler = gobjects(0);
renum = gobjects(0);
if isempty(ax)
    ruler = internal.hitRuler(evd);
    if ~isempty(ruler)
        switch(ruler.Axis)
            case 0
                renum = 'x';
            case 1
                renum = 'y';
            case 2
                renum = 'z';
        end
        ax = ancestor(ruler,'axes');
    end
end

ax = locValidateAxes(ax);

if isempty(ax)
    return
end

% always use first axes only
ax = ax(1);

% check for plotyy
ax = vectorizePlotyyAxes(ax);

%-----------------------------------------------%
function ax = locValidateAxes(allAxes)
ax = [];

for i=1:length(allAxes)
    candidate_ax=allAxes(i);
    if strcmpi(get(candidate_ax,'HandleVisibility'),'off') || ...
            isa(candidate_ax,'matlab.graphics.chart.Chart') %charts don't support behavior props
        % ignore this axes
        continue;
    end
    b = hggetbehavior(candidate_ax,'Pan','-peek');
    if ~isempty(b) && (ishandle(b) || isobject(b)) && ~get(b,'Enable')
        % ignore this axes

        % 'NonDataObject' is a legacy flag defined in
        % datachildren function.
    elseif ~isappdata(candidate_ax,'NonDataObject')
        ax = candidate_ax;
        break;
    end
end

%------------------------------------------------%
function cons = getConstraint(ax,constraint,modeStyle)
import matlab.graphics.interaction.internal.*

if strcmp(modeStyle,'xy')
    modeStyle = 'unconstrained';
end

fig = ancestor(ax,'figure');
if is2D(ax)
    cons = reconcileAxesAndFigureConstraints(constraint,modeStyle);
elseif ~strcmp(getAxes3DPanAndZoomStyle(fig,ax),'limits')
    cons = 'unconstrained';
else
    if isempty(constraint)
        cons = 'unconstrained';
    else
        cons = constraint;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%----------- Undo----------%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------%
function locCreateLimitUndo(ax,origlim,newlim)
% Create command structure

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
hFig = ancestor(ax(1),'Figure');
proxyVal = getProxyValueFromHandle(ax);

cmd.Name = 'Pan';

if numel(ax(1).YAxis) < 2
    cmd.Function = @locDoLimitUndo;
    cmd.Varargin = {hFig,proxyVal,newlim};
    % Use English for the name, it will get translated later on when it is
    % used in the Undo/Redo menu items.
    cmd.InverseFunction = @locDoLimitUndo;
    cmd.InverseVarargin = {hFig,proxyVal,origlim};
else
    origSide = ax.YAxisLocation;
    cmd.Function = @matlab.graphics.interaction.internal.doYYAxisUndo;
    cmd.Varargin = {@locDoLimitUndo,hFig,proxyVal,origSide,newlim};
    % Use English for the name, it will get translated later on when it is
    % used in the Undo/Redo menu items.
    cmd.InverseFunction = @matlab.graphics.interaction.internal.doYYAxisUndo;
    cmd.InverseVarargin = {@locDoLimitUndo,hFig,proxyVal,origSide,origlim};
end

% Register with undo
uiundo(hFig,'function',cmd);

%-----------------------------------------------%
function locDoLimitUndo(hFig,proxyVal,newlim)

ax = getHandleFromProxyValue(hFig,proxyVal);
for i = 1:length(ax)
    if ishghandle(ax(i))
        ax(i).XLim = newlim{i}{1};
        ax(i).YLim = newlim{i}{2};
        if numel(newlim{i}) > 2
            ax(i).ZLim = newlim{i}{3};
        end
    end
end

%------------------------------------------------%
function locCreate3DCameraUndo(ax,origtar,newtar,origpos,newpos)
% Create command structure

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
hFig = ancestor(ax,'Figure');
proxyVal = getProxyValueFromHandle(ax);

cmd.Function = @locDo3DCameraUndo;
cmd.Varargin = {hFig,proxyVal,newtar,newpos};
% Use English for the name, it will get translated later on when it is
% used in the Undo/Redo menu items.
cmd.Name = 'Pan';
cmd.InverseFunction = @locDo3DCameraUndo;
cmd.InverseVarargin = {hFig,proxyVal,origtar,origpos};

% Register with undo
uiundo(hFig,'function',cmd);

%------------------------------------------------%
function locDo3DCameraUndo(hFig,proxyVal,newtar,newpos)

ax = getHandleFromProxyValue(hFig,proxyVal);
for i = 1:length(ax)
    if ishghandle(ax(i))
        loc3DPan(ax(i),newtar{i},newpos{i});
    end
end

%-----------------------------------------------%
function loc3DPan(ax,newtar,newpos)

if ~iscell(newtar)
    newtar = {newtar};
    newpos = {newpos};
end

set(ax,{'CameraTarget'},newtar);
set(ax,{'CameraPosition'},newpos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%----------- KeyPress----------%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function locKeyPressFcn(fig,evd,hMode)
% Pan if the user clicks on arrow keys
import matlab.graphics.interaction.*

% Exit early if invalid event data
if ~isobject(evd) && (~isstruct(evd) || ~isfield(evd,'Key') || ...
        isempty(evd.Key) || ~isfield(evd,'Character'))
    return;
end

% If the mouse is down, return early:
if ~strcmp(hMode.ModeStateData.mouse,'off')
    return;
end
        
% Parse key press
ax = get(fig,'CurrentAxes');

ax = locValidateAxes(ax);
ax = vectorizePlotyyAxes(ax);

if ~isempty(ax) && ishghandle(ax(1))
    cons = getConstraint(ax(1), getPanBehaviorConstraint(ax(1)), hMode.ModeStateData.style);
    [enabled, constraint] = internal.pan.isPanEnabled(ax(1),cons,[]);
else
    enabled = false;
end

if ~enabled
    return;
end

consumekey = false;
isarrowkey = locIsArrowKey(evd.Key);
if ~isempty(ax) && ishghandle(ax(1))
    for i = 1:numel(ax)
        if isarrowkey
            [keyPressData(i), abort] = createArrowKeyPressData(fig, ax(i), constraint, evd); %#ok<AGROW>
            if abort
                consumekey = false;
            else
                localHandleArrowKey(hMode, ax, keyPressData);
                consumekey = true;
            end
        else
            consumekey = internal.performUndoRedoKeyPress(fig, evd.Modifier, evd.Key);
        end
    end

    % We only want the eventdata from the first keypress, so don't set these if
    % they've already been set.
    if isempty(get(hMode,'KeyReleaseFcn')) && isarrowkey
        set(hMode,'KeyReleaseFcn', @(obj,evd)locKeyReleaseFcn(obj,evd,ax,hMode,keyPressData));
        set(hMode,'WindowFocusLostFcn', @(obj,evd)locKeyReleaseFcn(obj,evd,ax,hMode,keyPressData));
    end
end

if ~consumekey
    graph2dhelper('forwardToCommandWindow',fig,evd);
end

function abort = abortKeyPressEarly(constraint, key)
% Abort early if constraint conflicts with arrow key
abort = false;
if ~isempty(constraint)
    switch constraint
        case 'x'
            if any(strcmp(key,{'uparrow','downarrow'}))
                abort = true;
            end
        case 'y'
            if any(strcmp(key,{'leftarrow','rightarrow'}))
                abort = true;
            end
    end
end

%------------------------------------------------%
function [keyPressData, abort] = createArrowKeyPressData(fig, ax, constraint, evd)
keyspeed = 5;
keyPressData = createButtonDownEventData(fig, ax, constraint,[0,0],[],[]);
abort = abortKeyPressEarly(constraint, evd.Key);
switch(evd.Key)
    case 'leftarrow'
        keyPressData.currPixel = [-keyspeed,0];
    case 'rightarrow'
        keyPressData.currPixel = [keyspeed,0];
    case 'uparrow'
        keyPressData.currPixel = [0,keyspeed];
    case 'downarrow'
        keyPressData.currPixel = [0,-keyspeed];
end
    
%------------------------------------------------%
function localHandleArrowKey(hMode, ax, keyPressData)
matlab.graphics.interaction.internal.initializeView(ax);

hMode.fireActionPreCallback(localConstructEvd(ax));
locDataPan(ax,keyPressData);
hMode.fireActionPostCallback(localConstructEvd(ax));

%------------------------------------------------%
function res = locIsArrowKey(key)
% Returns true if the key is an arrow key:

res = false;
if strcmpi(key,'uparrow') || strcmpi(key,'downarrow') || ...
        strcmpi(key,'leftarrow') || strcmpi(key,'rightarrow')
    res = true;
end

%------------------------------------------------%
function locKeyReleaseFcn(obj,evd,ax,hMode,keyPressData) %#ok

set(hMode,'KeyReleaseFcn', []);
set(hMode,'WindowFocusLostFcn', []);

if ~isempty(ax) && ishghandle(ax(1))
    locEndKey(ax,keyPressData)
end

%------------------------------------------------%
function locEndKey(ax,keyPressData)
% Register a key release with undo

if isscalar(keyPressData)
    if ~keyPressData.is2D && ~keyPressData.isLimitPanAndZoom
        newtar = {ax.CameraTarget};
        newpos = {ax.CameraPosition};
        origtar = {keyPressData.orig_target};
        origpos = {keyPressData.orig_pos};
        if ~isequal(newtar,origtar) || ~isequal(newpos,origpos)
            locCreate3DCameraUndo(ax,origtar,newtar,origpos,newpos);
        end
    else % 2D and 3D limit pan
        origlim = keyPressData.orig_axlim_datatyped;
        newlim = matlab.graphics.interaction.getAxesLimits(ax);
        if ~isequal(newlim{1},origlim{1})
            locCreateLimitUndo(ax,{origlim},newlim);       
        end
    end
else % plotyy
    for i = 1:numel(keyPressData)
        origlim{1} = keyPressData(1).orig_axlim_datatyped;
        origlim{2} = keyPressData(2).orig_axlim_datatyped;
    end
    newlim = matlab.graphics.interaction.getAxesLimits(ax);
    if ~isequal(newlim{1},origlim{1})
        locCreateLimitUndo(ax,origlim,newlim);       
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%----------- 3D Limit Pan----------%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------%
function new_limits = constrainedAxisPan(rulernum,planenum,orig_limits,orig_ray,curr_ray)
import matlab.graphics.interaction.internal.pan.*
normal = zeros(3,1);

% planenum is decided in the buttonDown and is based on which of the two
% planes (x will choose either y or z for example) gives the best numerics.
if planenum == 1
    % For x, project currentpoint ray onto y plane and then just use x values
    % For y, project currentpoint ray onto z plane and then just use y values
    % For z, project currentpoint ray onto x plane and then just use z values
    normal(mod(rulernum,3)+1) = 1;
    d = findProjectedVectorOnPlane(orig_ray, curr_ray, normal);
elseif planenum == 2
    % For x, project currentpoint ray onto z plane and then just use x values
    % For y, project currentpoint ray onto x plane and then just use y values
    % For z, project currentpoint ray onto y plane and then just use z values
    normal(mod(rulernum+1,3)+1) = 1;
    d = findProjectedVectorOnPlane(orig_ray, curr_ray, normal);
end

delta = zeros(3,1);
delta(rulernum) = d(rulernum);
new_limits = calculatePannedLimits(orig_limits,delta);


%-----------------------------------------------%
function new_limits = constrainedPlanePan(orig_limits,normal,orig_ray,curr_ray)
import matlab.graphics.interaction.internal.pan.*
delta = findProjectedVectorOnPlane(orig_ray, curr_ray, normal);
new_limits = calculatePannedLimits(orig_limits,delta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%------- 3D Camera -------%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function [newcp, newct] = camdollyGivenData(axpos, dx, dy, dar, cp, ct, up, cva)

v = (ct-cp)./dar;
dis = norm(v);
r = cross(v, up./dar);
u = cross(r, v);

r = r/norm(r);
u = u/norm(u);

fov = 2*dis*tan(cva/2*pi/180);
pix = min(axpos(3), axpos(4));
delta = fov/pix .* dar .* ((dx * r) + (dy * u));

newcp = cp+delta;
newct = ct+delta;

%-----------------------------------------------%
function val=righthanded(ax)

dirs=get(ax, {'xdir' 'ydir' 'zdir'}); 
num=length(find(lower(cat(2,dirs{:}))=='n'));

val = mod(num,2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%-------2D Helpers -------%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function new_lims = constrain_lims(uncon_lims, orig_lims, e)
new_lims = orig_lims;
switch e
    case 'x'
        new_lims(1:2) = uncon_lims(1:2);
    case 'y'
        new_lims(3:4) = uncon_lims(3:4);
    case 'z'
        new_lims(5:6) = uncon_lims(5:6);
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%-------Broadcasting Mode Changes -------%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function locDoPanOn(hMode)

set(uigettoolFromModeCache(hMode,'Exploration.Pan','ToolbarButton'),'State','on');
set(uifindallFromModeCache(hMode,'figMenuPan','MenuItem'),'Checked','on');

%Refresh context menu
hui = get(hMode,'UIContextMenu');
if ishghandle(hMode.ModeStateData.CustomContextMenu)
    set(hMode,'UIContextMenu',hMode.ModeStateData.CustomContextMenu);
elseif ishghandle(hui)
    delete(hui);
    set(hMode,'UIContextMenu','');
end

%-----------------------------------------------%
function locDoPanOff(hMode)

set(uigettoolFromModeCache(hMode,'Exploration.Pan','ToolbarButton'),'State','off');
set(uifindallFromModeCache(hMode,'figMenuPan','MenuItem'),'Checked','off');

hui = hMode.UIContextMenu;
if (~isempty(hui) && ishghandle(hui)) && ...
        (isempty(hMode.ModeStateData.CustomContextMenu) || ~ishghandle(hMode.ModeStateData.CustomContextMenu))
    delete(hui);
    hMode.UIContextMenu = '';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%-------Context Menu-------%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------------------------------------------%
function [hui] = locUICreateDefaultContextMenu(hMode)
% Create default context menu

hFig = hMode.FigureHandle;

props = [];
props_context.Parent = hFig;
props_context.Tag = 'PanContextMenu';
props_context.Serializable = 'off';
props_context.Callback = {@locUIContextMenuCallback,hMode};
props_context.ButtonDownFcn = {@locUIContextMenuCallback,hMode};
hMode.UIContextMenu = uicontextmenu(props_context);
hui = hMode.UIContextMenu;

% Generic attributes for all pan context menus
props.Callback = {@locUIContextMenuCallback,hMode};
props.Parent = hui;

% Full View context menu
props.Label = getString(message('MATLAB:uistring:pan:ResetToOriginalView'));
props.Tag = 'ResetView';
props.Separator = 'off';
ufullview = uimenu(props); %#ok

props.Label = getString(message('MATLAB:uistring:interaction:LimitsPanandZoom'));
props.Tag = 'limits';
props.Separator = 'on';
lim = uimenu(props);

props.Label = getString(message('MATLAB:uistring:interaction:CameraPanandZoom'));
props.Tag = 'camera';
props.Separator = 'off';
cam = uimenu(props);

% 2D submenu
props.Callback = {@locUIContextMenuCallback,hMode};
props.Label = getString(message('MATLAB:uistring:pan:UnconstrainedPan'));
props.Tag = 'PanUnconstrained2D';
props.Separator = 'on';
h2D(1) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:HorizontalPan'));
props.Tag = 'PanHorizontal';
props.Separator = 'off';
h2D(2) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:VerticalPan'));
props.Tag = 'PanVertical';
h2D(3) = uimenu(props);

% 3D submenu
props.Callback = {@loc3DUIContextMenuCallback,hMode};
props.Label = getString(message('MATLAB:uistring:pan:UnconstrainedPan'));
props.Tag = 'unconstrained';
props.Separator = 'on';
h3D(1) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:XPan'));
props.Tag = 'x';
props.Separator = 'off';
h3D(2) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:YPan'));
props.Tag = 'y';
h3D(3) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:ZPan'));
props.Tag = 'z';
h3D(4) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:XYPan'));
props.Tag = 'xy';
h3D(5) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:YZPan'));
props.Tag = 'yz';
h3D(6) = uimenu(props);

props.Label = getString(message('MATLAB:uistring:pan:XZPan'));
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

%-------------------------------------------------%
function locUIContextMenuCallback(obj,~,hMode)
import matlab.graphics.interaction.*
tag = get(obj,'tag');

allAxes = hMode.FigureState.CurrentAxes;
allAxes = locValidateAxes(allAxes);
allAxes = allAxes(1);
hAxes = matlab.graphics.interaction.vectorizePlotyyAxes(allAxes);

switch(tag)
    case 'PanContextMenu'
        if is2D(hAxes(1))
            localUIContextMenuUpdate2DConstraint(hMode,hMode.ModeStateData.style);
            set(obj.Constraints2D,'Visible','on');
            set(obj.Constraints3D,'Visible','off');
            set(obj.Camera,'Visible','off');
            set(obj.Limits,'Visible','off');
        else
            hFig = hMode.FigureHandle;
            internal.updateUIContextMenu3DVersion(hFig,'none',hAxes);
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
    case 'ResetView'
        % If we are here, then we clicked on something contained in an
        % axes. Rather than calling HITTEST, we will get this information
        % manually.
        hMode.fireActionPreCallback(localConstructEvd(hAxes));
        locReturnHome(hAxes);
        hMode.fireActionPostCallback(localConstructEvd(hAxes));
    case 'PanUnconstrained2D'
        localUIContextMenuUpdate2DConstraint(hMode,'xy');
    case 'PanHorizontal'
        localUIContextMenuUpdate2DConstraint(hMode,'x');
    case 'PanVertical'
        localUIContextMenuUpdate2DConstraint(hMode,'y');
    case 'camera'
        internal.updateUIContextMenu3DVersion(hMode.FigureHandle,'camera',hAxes);
    case 'limits'
        internal.updateUIContextMenu3DVersion(hMode.FigureHandle,'limits',hAxes);        
end

%-------------------------------------------------%
function loc3DUIContextMenuCallback(obj,~,hMode)

tag = get(obj,'tag');

allAxes = hMode.FigureState.CurrentAxes;
hAxes = locValidateAxes(allAxes);

updateUIContextMenu3DConstraint(hMode.FigureHandle,hAxes,tag);

%-------------------------------------------------%
function updateUIContextMenu3DConstraint(hFigure,hAxes,cons)
consStrings = {'x','y','z','xy','yz','xz','unconstrained'};
for i = 1:numel(consStrings)
    consMenus(i) = findall(hFigure,'Tag',consStrings{i},'Type','UIMenu'); %#ok<AGROW>
end

if ~strcmp(cons,'default')
    setPanBehaviorConstraint(hAxes,cons);
else
    % for a new contextmenu, use the behavior object to determine which menu
    % item should be checked
    cons = getPanBehaviorConstraint(hAxes);
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
function cons = getPanBehaviorConstraint(hAxes)

localBehavior = hggetbehavior(hAxes,'Pan','-peek');
if ~isempty(localBehavior)
    cons = localBehavior.Constraint3D;
else
    cons = [];
end

%-------------------------------------------------%
function cons = setPanBehaviorConstraint(hAxes, cons)

localBehavior = hggetbehavior(hAxes,'Pan');
localBehavior.Constraint3D = cons;    

%-------------------------------------------------%
function localUIContextMenuUpdate2DConstraint(hMode,pan_Constraint)

hFig = hMode.FigureHandle;

uimenus = findall(hFig,'Type','UIMenu');
ux = findall(uimenus,'Tag','PanHorizontal');
uy = findall(uimenus,'Tag','PanVertical');
uxy = findall(uimenus,'Tag','PanUnconstrained2D');

hMode.ModeStateData.style = pan_Constraint;

switch(pan_Constraint)
    case 'xy'
        set(ux,'checked','off');
        set(uy,'checked','off');
        set(uxy,'checked','on');

    case 'x'
        set(ux,'checked','on');
        set(uy,'checked','off');
        set(uxy,'checked','off');

    case 'y'
        set(ux,'checked','off');
        set(uy,'checked','on');
        set(uxy,'checked','off');
end
