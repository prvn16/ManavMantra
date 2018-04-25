classdef (CaseInsensitiveProperties = true) zoom < matlab.graphics.interaction.internal.exploreaccessor
%matlab.graphics.interaction.internal.zoom class extends matlab.graphics.interaction.internal.exploreaccessor
%
%    zoom properties:
%       ButtonDownFilter - Property is of type 'MATLAB callback'  
%       ActionPreCallback - Property is of type 'MATLAB callback'  
%       ActionPostCallback - Property is of type 'MATLAB callback'  
%       Enable - Property is of type 'on/off'  
%       FigureHandle - Property is of type 'MATLAB array' (read only) 
%       Motion - Property is of type 'StyleChoice enumeration: {'horizontal','vertical','both'}'  
%       Direction - Property is of type 'in/out enumeration: {'in','out'}'  
%       RightClickAction - Property is of type 'RightClickActionType enumeration: {'InverseZoom','PostContextMenu'}'  
%       UIContextMenu - Property is of type 'MATLAB array'  
%
%    graphics.zoom methods:
%       getAxesZoomMotion -  Given an axes, determine the style of zoom allowed
%       isAllowAxesZoom -  Given an axes, determine whether zooming is allowed
%       setAllowAxesZoom -  Given an axes, determine whether zoom is allowed
%       setAxesZoomMotion -  Given an axes, determine the style of pan allowed
%   Copyright 2013-2014 The MathWorks, Inc.

properties (AbortSet, SetObservable, GetObservable)
    Motion = 'horizontal'; % enumeration: {'horizontal','vertical','both'}' 
    Direction = 'in';% enumeration: {'in','out'}'
    RightClickAction = 'InverseZoom';% enumeration: {'InverseZoom','PostContextMenu'}'
    UIContextMenu = [];
end


methods  % constructor block
    function [hThis] = zoom(hMode)
        % Constructor for the zoom mode accessor
        hThis = hThis@matlab.graphics.interaction.internal.exploreaccessor(hMode);
        
        if ~isvalid(hMode) || ~isa(hMode,'matlab.uitools.internal.uimode')
            error(message('MATLAB:graphics:zoom:InvalidConstructor'));
        end
        if ~strcmpi(hMode.Name,'Exploration.Zoom')
            error(message('MATLAB:graphics:zoom:InvalidConstructor'));
        end
        if isfield(hMode.ModeStateData,'accessor') && ...
                ishandle(hMode.ModeStateData.accessor)
            error(message('MATLAB:graphics:zoom:AccessorExists'));
        end
       
        set(hThis,'ModeHandle',hMode);
        
        % Add a listener on the figure to destroy this object upon figure deletion
        addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));
    end  % zoom
    
end  % constructor block

methods 
    function value = get.Motion(obj)
        value = localGetStyle(obj,obj.Motion);
    end
    function set.Motion(obj,value)
        value = validatestring(value,{'horizontal','vertical','both'},'','Motion');
        obj.Motion = localSetStyle(obj,value);
    end

    function value = get.Direction(obj)
        value = localGetDirection(obj,obj.Direction);
    end
    function set.Direction(obj,value)
        value = validatestring(value,{'in','out'},'','Direction');
        obj.Direction = localSetDirection(obj,value);
    end

    function value = get.RightClickAction(obj)
        value = localGetRightClickZoomOut(obj,obj.RightClickAction);
    end
    function set.RightClickAction(obj,value)
        value = validatestring(value,{'InverseZoom','PostContextMenu'},'','RightClickAction');
        obj.RightClickAction = localSetRightClickZoomOut(obj,value);
    end

    function value = get.UIContextMenu(obj)
        value = localGetContextMenu(obj,obj.UIContextMenu);
    end
    function set.UIContextMenu(obj,value)
        obj.UIContextMenu = localSetContextMenu(obj,value);
    end
end   % set and get functions 

methods  %% public methods
    style = getAxesZoomMotion(hThis,hAx)
    res = isAllowAxesZoom(hThis,hAx)
    ver3d = getAxes3DPanAndZoomStyle(hThis,hAx);
    cons = getAxesZoomConstraint(hThis,hAx);
	
    setAllowAxesZoom(hThis,hAx,flag)
    setAxesZoomMotion(hThis,hAx,style)
    setAxes3DPanAndZoomStyle(hThis,hAx,ver3d);
	setAxesZoomConstraint(hThis,hAx,cons);
end  %% public methods 

end  % classdef


%-----------------------------------------------%
function valueToCaller = localGetRightClickZoomOut(hThis,~)
if strcmpi(hThis.ModeHandle.ModeStateData.DoRightClick,'on')
    valueToCaller = 'InverseZoom';
else
    valueToCaller = 'PostContextMenu';
end
end  % localGetRightClickZoomOut


%-----------------------------------------------%
function newValue = localSetRightClickZoomOut(hThis,valueProposed)
newValue = valueProposed;
% Save the right click zoom option as a preference
if strcmpi(valueProposed,'InverseZoom')
    hThis.ModeHandle.ModeStateData.DoRightClick = 'on';
    setpref('MATLABZoom','RightClick','on');
else
    hThis.ModeHandle.ModeStateData.DoRightClick = 'off';
    setpref('MATLABZoom','RightClick','off');
end
end  % localSetRightClickZoomOut


%-----------------------------------------------%
function valueToCaller = localGetStyle(hThis,~)
% Get the current zoom style
constraint = hThis.ModeHandle.ModeStateData.Constraint;
if strcmpi(constraint,'none')
    valueToCaller = 'both';
else
    valueToCaller = constraint;
end
end  % localGetStyle


%-----------------------------------------------%
function newValue = localSetStyle(hThis,valueProposed)
% Set the current zoom style
newValue = valueProposed;
if strcmpi(valueProposed,'both')
    valueProposed = 'none';
end
% If the mode is running and the direction is "in", update the UI:
if isactiveuimode(hThis.FigureHandle,'Exploration.Zoom')
    if strcmpi(hThis.ModeHandle.ModeStateData.Direction,'in')
        localUIChangeConstraint(hThis.FigureHandle,valueProposed);
    end
end
hThis.ModeHandle.ModeStateData.Constraint = valueProposed;
end  % localSetStyle


%-----------------------------------------------%
function valueToCaller = localGetDirection(hThis,~)
% Get the current direction of the mode
valueToCaller = hThis.ModeHandle.ModeStateData.Direction;
end  % localGetDirection


%-----------------------------------------------%
function newValue = localSetDirection(hThis,valueProposed)
% Modify the User interface if the direction is changed while the mode is
% running.

hMode = hThis.ModeHandle;
newValue = valueProposed;

if isactiveuimode(hMode.FigureHandle,'Exploration.Zoom')
    if strcmp(valueProposed,'in')
        xTool = uigettool(hMode.FigureHandle,'Exploration.ZoomX');
        if isempty(xTool)
            localUISetZoomIn(hMode.FigureHandle);
        else
            localUIChangeConstraint(hMode.FigureHandle,hMode.ModeStateData.Constraint);
        end
    else
        localUISetZoomOut(hMode.FigureHandle);
    end
end
hMode.ModeStateData.Direction = newValue;
end  % localSetDirection


%-----------------------------------------------%
function valueToCaller = localGetContextMenu(hThis,~)
valueToCaller = hThis.ModeHandle.ModeStateData.CustomContextMenu;
end  % localGetContextMenu


%-----------------------------------------------%
function newValue = localSetContextMenu(hThis,valueProposed)
if strcmpi(hThis.Enable,'on')
    error(message('MATLAB:graphics:zoom:ReadOnlyRunning'));
end
if ~isempty(valueProposed) && ~ishghandle(valueProposed,'uicontextmenu')
    error(message('MATLAB:graphics:zoom:InvalidContextMenu'));
end
newValue = valueProposed;
hThis.ModeHandle.ModeStateData.CustomContextMenu = valueProposed;
end  % localSetContextMenu


%-----------------------------------------------%
function localUIChangeConstraint(fig,constraint)
% Change the UI to match the constraint.

switch constraint
    case 'none'
        localUISetZoomIn(fig);
    case 'horizontal'
        localUISetZoomInX(fig);
    case 'vertical'
        localUISetZoomInY(fig);
end
end  % localUIChangeConstraint


% This function is identical to the one found in zoom.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomIn(fig)
set(uigettool(fig,'Exploration.ZoomIn'),'State','on');
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
set(uigettool(fig,'Exploration.ZoomX'),'State','off');
set(uigettool(fig,'Exploration.ZoomY'),'State','off');
set(findall(fig,'Tag','figMenuZoomIn'), 'Checked', 'on');
set(findall(fig,'Tag','figMenuZoomOut'),'Checked', 'off');
end  % localUISetZoomIn


% This function is identical to the one found in zoom.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomInX(fig)
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
hZoomX = uigettool(fig,'Exploration.ZoomX');
% If there is no X button, this is the same as in mode:
if isempty(hZoomX)
    set(uigettool(fig,'Exploration.ZoomIn'),'State','on');
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
else
    set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
    set(hZoomX,'State','on');
    set(uigettool(fig,'Exploration.ZoomY'),'State','off');
end
end  % localUISetZoomInX


% This function is identical to the one found in zoom.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomInY(fig)
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
hZoomX = uigettool(fig,'Exploration.ZoomX');
% If there is no X button, this is the same as in mode:
if isempty(hZoomX)
    set(uigettool(fig,'Exploration.ZoomIn'),'State','on');
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
else
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
    set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
    set(hZoomX,'State','off');
    set(uigettool(fig,'Exploration.ZoomY'),'State','on');
end
end  % localUISetZoomInY


% This function is identical to the one found in zoom.m.  If you modify
% this function, modify that one as well.  There is no good central
% repository for this code at this time.
%-----------------------------------------------%
function localUISetZoomOut(fig)
set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
set(uigettool(fig,'Exploration.ZoomOut'),'State','on');
set(uigettool(fig,'Exploration.ZoomX'),'State','off');
set(uigettool(fig,'Exploration.ZoomY'),'State','off');
set(findall(fig,'Tag','figMenuZoomIn'), 'Checked', 'off');
set(findall(fig,'Tag','figMenuZoomOut'),'Checked', 'on');
end  % localUISetZoomOut
