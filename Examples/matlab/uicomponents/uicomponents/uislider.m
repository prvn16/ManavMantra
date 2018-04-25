function sliderComponent = uislider(varargin)
%UISLIDER Create slider component 
%   slider = UISLIDER creates a slider in a new UI figure window.
%
%   slider = UISLIDER(parent) specifies the object in which to 
%   create the slider.
%
%   slider = UISLIDER( ___ ,Name,Value) specifies slider properties using
%   one or more Name,Value pair arguments. Use this option with any of the
%   input argument combinations in the previous syntaxes.
%
%   Example 1: Create a Slider
%      slider = uislider;
%
%   Example 2: Specify the Parent Object for a Slider
%      fig = uifigure;
%      slider = uislider(fig);
%
%   See also UIFIGURE, UIGAUGE, UIKNOB, UISPINNER

%   Copyright 2017 The MathWorks, Inc.

className = 'matlab.ui.control.Slider';

messageCatalogID = 'uislider';

try
    sliderComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...        
        className, ...
        messageCatalogID,...
        varargin{:});
    
catch ex
    error('MATLAB:ui:Slider:unknownInput', ...
        ex.message);
end
