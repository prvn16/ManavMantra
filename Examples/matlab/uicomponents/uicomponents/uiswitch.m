function switchComponent = uiswitch(varargin)
%UISWITCH Create slider switch, rocker switch, or toggle switch component
%   control = UISWITCH creates a slider switch component 
%   in a new UI figure window.
%
%   control = UISWITCH(style) creates a switch of the specified style.
%
%   control = UISWITCH(parent) specifies the object in which to
%   create the switch.
%
%   control = UISWITCH(parent,style) creates a switch of the specified
%   style in the specified parent object.
%
%   control = UISWITCH( ___ ,Name,Value) specifies switch properties using
%   one or more Name,Value pair arguments. Use this option with any of the
%   input argument combinations in the previous syntaxes.
%
%   Example 1: Create a Slider Switch
%      % Create a slider switch, the default switch style is a slider switch.
%      sliderswitch = uiswitch;
%
%   Example 2: Create a Toggle Switch
%      % Create a toggle switch by specifying the style as toggle.
%      toggleswitch = uiswitch('toggle');
%
%   Example 3: Specify the Parent Object for a Rocker Switch
%      % Specify a UI figure window as the parent object
%      % for a rocker switch.
%      fig = uifigure;
%      rockerswitch = uiswitch(fig,'rocker');
%
%   See also UIFIGURE, UIBUTTON, UICHECKBOX, UIRADIOBUTTON, UITOGGLEBUTTON

%   Copyright 2017 The MathWorks, Inc.

styleNames = {...
    'slider', ...
    'toggle', ...
    'rocker' ...
    };

classNames = {...
    'matlab.ui.control.Switch', ...
    'matlab.ui.control.ToggleSwitch',  ... 
    'matlab.ui.control.RockerSwitch' ...
   
    };

defaultClassName = 'matlab.ui.control.Switch';

messageCatalogID = 'uiswitch';

try
    switchComponent = matlab.ui.control.internal.model.ComponentCreation.createComponentInFamily(...
        styleNames, ...
        classNames, ...
        defaultClassName, ...
        messageCatalogID,...        
        varargin{:});
catch ex
      error('MATLAB:ui:Switch:unknownInput', ...
        ex.message);
end