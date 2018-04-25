classdef (CaseInsensitiveProperties = true) pan < matlab.graphics.interaction.internal.exploreaccessor
%matlab.graphics.interaction.internal.pan class extends matlab.graphics.interaction.internal.exploreaccessor
%
% pan properties:
%       ButtonDownFilter - Property is of type 'MATLAB callback'  
%       ActionPreCallback - Property is of type 'MATLAB callback'  
%       ActionPostCallback - Property is of type 'MATLAB callback'  
%       Enable - Property is of type 'on/off'  
%       FigureHandle - Property is of type 'MATLAB array' (read only) 
%       Motion - Property is of type 'StyleChoice enumeration: {'horizontal','vertical','both'}'  
%       UIContextMenu - Property is of type 'MATLAB array'  
%
%    graphics.pan methods:
%       getAxesPanMotion -  Given an axes, determine the style of pan allowed
%       isAllowAxesPan -  Given an axes, determine whether panning is allowed
%       setAllowAxesPan -  Given an axes, determine whether pan is allowed
%       setAxesPanMotion -  Given an axes, determine the style of pan allowed

%   Copyright 2013 The MathWorks, Inc.

properties (AbortSet, SetObservable, GetObservable)
    %MOTION Property is of type 'StyleChoice enumeration: {'horizontal','vertical','both'}' 
    Motion = 'horizontal';
    %UICONTEXTMENU Property is of type 'MATLAB array' 
    UIContextMenu = [];
end


methods  % constructor block
    function [hThis] = pan(hMode)
    % Constructor for the pan mode accessor
    hThis = hThis@matlab.graphics.interaction.internal.exploreaccessor(hMode);

    % Syntax: graphics.pan(mode)
    if ~isvalid(hMode) || ~isa(hMode,'matlab.uitools.internal.uimode')
        error(message('MATLAB:graphics:pan:InvalidConstructor'));
    end
    if ~strcmpi(hMode.Name,'Exploration.Pan')
        error(message('MATLAB:graphics:pan:InvalidConstructor'));
    end
    if isfield(hMode.ModeStateData,'accessor') && ...
            ishandle(hMode.ModeStateData.accessor)
        error(message('MATLAB:graphics:pan:AccessorExists'));
    end
   
    set(hThis,'ModeHandle',hMode);
    
    % Add a listener on the figure to destroy this object upon figure deletion
    addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));
    end  % pan
    
end  % constructor block

methods 
    function value = get.Motion(obj)
        value = localGetStyle(obj,obj.Motion);
    end
    function set.Motion(obj,value)
        % Enumerated DataType = 'StyleChoice enumeration: {'horizontal','vertical','both'}'
        value = validatestring(value,{'horizontal','vertical','both'},'','Motion');
        obj.Motion = localSetStyle(obj,value);
    end

    function value = get.UIContextMenu(obj)
        value = localGetContextMenu(obj,obj.UIContextMenu);
    end
    function set.UIContextMenu(obj,value)
        obj.UIContextMenu = localSetContextMenu(obj,value);
    end
end   % set and get functions 

methods  %% public methods
    style = getAxesPanMotion(hThis,hAx)
    res = isAllowAxesPan(hThis,hAx)
    style3D = getAxes3DPanAndZoomStyle(hThis,hAx);
    cons = getAxesPanConstraint(hThis,hAx);
    
    setAllowAxesPan(hThis,hAx,flag)
    setAxesPanMotion(hThis,hAx,style)
    setAxes3DPanAndZoomStyle(hThis,hAx,style);
    setAxesPanConstraint(hThis,hAx,cons);
end  %% public methods 

end  % classdef

%------------------------------------------------------------------------%
function newValue = localSetStyle(hThis,valueProposed)
% Set the style property of the mode
switch valueProposed
    case 'horizontal'
        hThis.ModeHandle.ModeStateData.style = 'x';
        newValue = valueProposed;
    case 'vertical'
        hThis.ModeHandle.ModeStateData.style = 'y';
        newValue = valueProposed;
    case 'both'
        hThis.ModeHandle.ModeStateData.style = 'xy';
        newValue = valueProposed;
end
end  % localSetStyle


%------------------------------------------------------------------------%
function valueToCaller = localGetStyle(hThis,~)
% Get the style property from the mode
styleChoice = hThis.ModeHandle.ModeStateData.style;
switch styleChoice
    case 'x'
        valueToCaller = 'horizontal';
    case 'y'
        valueToCaller = 'vertical';
    case 'xy'
        valueToCaller = 'both';
end
end  % localGetStyle


%-----------------------------------------------%
function valueToCaller = localGetContextMenu(hThis,~)
valueToCaller = hThis.ModeHandle.ModeStateData.CustomContextMenu;
end  % localGetContextMenu


%-----------------------------------------------%
function newValue = localSetContextMenu(hThis,valueProposed)
if strcmpi(hThis.Enable,'on')
    error(message('MATLAB:graphics:pan:ReadOnlyRunning'));
end
if ~isempty(valueProposed) && ~ishghandle(valueProposed,'uicontextmenu')
    error(message('MATLAB:graphics:pan:InvalidContextMenu'));
end
newValue = valueProposed;
    hThis.ModeHandle.ModeStateData.CustomContextMenu = valueProposed;
end  % localSetContextMenu

