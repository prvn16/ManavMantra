classdef (CaseInsensitiveProperties = true) brush < matlab.graphics.interaction.internal.exploreaccessor & JavaVisible
%matlab.graphics.interaction.internal.brush class extends matlab.graphics.interaction.internal.exploreaccessor
%    brush properties:
%       ButtonDownFilter - Property is of type 'MATLAB callback'  
%       ActionPreCallback - Property is of type 'MATLAB callback'  
%       ActionPostCallback - Property is of type 'MATLAB callback'  
%       Enable - Property is of type 'on/off'  
%       FigureHandle - Property is of type 'MATLAB array' (read only) 
%       Color - Property is of type 'lineColorType'  

%   Copyright 2013 The MathWorks, Inc.

properties (AbortSet, SetObservable, GetObservable)
    %COLOR Property is of type 'lineColorType' 
    Color = [];
end


methods  % constructor block
    function [hThis] = brush(hMode)
    % Constructor for the brush mode accessor
    hThis = hThis@matlab.graphics.interaction.internal.exploreaccessor(hMode);

    % Syntax: graphics.brush(mode)
    if ~isvalid(hMode) || ~isa(hMode,'matlab.uitools.internal.uimode')
        error(message('MATLAB:graphics:brush:InvalidConstructor'));
    end
    if ~strcmpi(hMode.Name,'Exploration.Brushing')
        error(message('MATLAB:graphics:brush:InvalidConstructor'));
    end
    if ~isempty(hMode.ModeStateData.accessor) && ...
            ishandle(hMode.ModeStateData.accessor)
        error(message('MATLAB:graphics:brush:AccessorExists'));
    end
    
    set(hThis,'ModeHandle',hMode);
    
    % Add a listener on the figure to destroy this object upon figure deletion
    addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));
    end  % brush
    
end  % constructor block

methods 
    function value = get.Color(obj)
        value = localGetColor(obj,obj.Color);
    end
    function set.Color(obj,value)
        % DataType = 'lineColorType'
        obj.Color = localSetColor(obj,value);
    end

end   % set and get functions 
end  % classdef

function newValue = localSetColor(hThis,valueProposed)
% MCOS typecasts valueProposed to single instead of double; 
% explicitly typecasting it to double. Needed for correct color setting.
if isnumeric(valueProposed)
    valueProposed = double(valueProposed);
end    
brush(hThis.FigureHandle,valueProposed)
newValue = valueProposed;
end  % localSetColor


%------------------------------------------------------------------------%
function valueToCaller = localGetColor(hThis,valueStored)
% Get the Color property from the mode
valueToCaller = hThis.ModeHandle.ModeStateData.color;
end  % localGetColor
