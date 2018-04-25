classdef (CaseInsensitiveProperties = true) rotate3d < matlab.graphics.interaction.internal.exploreaccessor
%matlab.graphics.interaction.internal.rotate3d class extends matlab.graphics.interaction.internal.exploreaccessor
%
%    rotate3d properties:
%       ButtonDownFilter - Property is of type 'MATLAB callback'  
%       ActionPreCallback - Property is of type 'MATLAB callback'  
%       ActionPostCallback - Property is of type 'MATLAB callback'  
%       Enable - Property is of type 'on/off'  
%       FigureHandle - Property is of type 'MATLAB array' (read only) 
%       RotateStyle - Property is of type 'RotateStyle enumeration: {'box','orbit'}'  
%       UIContextMenu - Property is of type 'MATLAB array'  
%
%    graphics.rotate3d methods:
%       isAllowAxesRotate -  Given an axes, determine whether panning is allowed
%       setAllowAxesRotate -  Given an axes, determine whether rotate3d is allowed

%   Copyright 2013 The MathWorks, Inc.

properties (AbortSet, SetObservable, GetObservable)
    %ROTATESTYLE Property is of type 'RotateStyle enumeration: {'box','orbit'}' 
    RotateStyle = 'box';
    %UICONTEXTMENU Property is of type 'MATLAB array' 
    UIContextMenu = [];
end


methods  % constructor block
    function [hThis] = rotate3d(hMode)
    % Constructor for the rotate3d mode accessor
    hThis = hThis@matlab.graphics.interaction.internal.exploreaccessor(hMode);
    
    % Syntax: matlab.graphics.internal.rotate3d(mode)
    if ~isvalid(hMode) || ~isa(hMode,'matlab.uitools.internal.uimode')
        error(message('MATLAB:graphics:rotate3d:InvalidConstructor'));
    end
    if ~strcmpi(hMode.Name,'Exploration.Rotate3d')
        error(message('MATLAB:graphics:rotate3d:InvalidConstructor'));
    end
    if isfield(hMode.ModeStateData,'accessor') && ...
            ishandle(hMode.ModeStateData.accessor)
        error(message('MATLAB:graphics:rotate3d:AccessorExists'));
    end
    
    set(hThis,'ModeHandle',hMode);
    
    % Add a listener on the figure to destroy this object upon figure deletion
    addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));
    end  % rotate3d
    
end  % constructor block

methods 
    function value = get.RotateStyle(obj)
        value = localGetStyle(obj,obj.RotateStyle);
    end
    function set.RotateStyle(obj,value)
        % Enumerated DataType = 'RotateStyle enumeration: {'box','orbit'}'
        value = validatestring(value,{'box','orbit'},'','RotateStyle');
        obj.RotateStyle = localSetStyle(obj,value);
    end

    function value = get.UIContextMenu(obj)
        value = localGetContextMenu(obj,obj.UIContextMenu);
    end
    function set.UIContextMenu(obj,value)
        obj.UIContextMenu = localSetContextMenu(obj,value);
    end

end   % set and get functions 

methods  %% public methods
    res = isAllowAxesRotate(hThis,hAx)
    setAllowAxesRotate(hThis,hAx,flag)
end  %% public methods 

end  % classdef

function newValue = localSetStyle(hThis,valueProposed)
% Set the style property of the mode
switch valueProposed
    case 'box'
        hThis.ModeHandle.ModeStateData.rotatestyle = '-view';
        newValue = valueProposed;
    case 'orbit'
        hThis.ModeHandle.ModeStateData.rotatestyle = '-orbit';
        newValue = valueProposed;
end
end  % localSetStyle


%------------------------------------------------------------------------%
function valueToCaller = localGetStyle(hThis,~)
% Get the style property from the mode
styleChoice = hThis.ModeHandle.ModeStateData.rotatestyle;
switch styleChoice
    case '-view'
        valueToCaller = 'box';
    case '-orbit'
        valueToCaller = 'orbit';
end
end  % localGetStyle


%-----------------------------------------------%
function valueToCaller = localGetContextMenu(hThis,~)
valueToCaller = hThis.ModeHandle.ModeStateData.CustomContextMenu;
end  % localGetContextMenu


%-----------------------------------------------%
function newValue = localSetContextMenu(hThis,valueProposed)
if strcmpi(hThis.Enable,'on')
    error(message('MATLAB:graphics:rotate3d:ReadOnlyRunning'));
end
if ~isempty(valueProposed) && ~ishghandle(valueProposed,'uicontextmenu')
    error(message('MATLAB:graphics:rotate3d:InvalidContextMenu'));
end
newValue = valueProposed;
    hThis.ModeHandle.ModeStateData.CustomContextMenu = valueProposed;
end  % localSetContextMenu

