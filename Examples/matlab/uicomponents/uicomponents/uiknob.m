function knobComponent = uiknob(varargin)
%UIKNOB Create knob or discrete knob component
%   knob = UIKNOB creates a knob in a new UI figure window and returns a 
%   handle to the Knob object.
%
%   knob = UIKNOB(style) specifies the knob style.
%
%   knob = UIKNOB(parent) specifies the object in which to create the knob.
%
%   knob = UIKNOB(parent,style) creates a knob of the specified style in 
%   the specified parent object.
%
%   knob = UIKNOB( ___ ,Name,Value) specifies knob properties using one or
%   more Name,Value pair arguments. Use this option with any of the input 
%   argument combinations in the previous syntaxes.
%
%   Example 1: Create a Default Knob
%      % Create a continuous knob in a default UI figure window.
%      knob = uiknob;
%
%   Example 2: Create a Discrete Knob in a UI Figure Window
%      knob = uiknob('discrete');
%
%   Example 3: Specify the Parent Object for a Discrete Knob
%      % Specify a small UI figure window as the parent for a discrete knob.
%      fig = uifigure('Position',[100 100 300 250]);
%      knob = uiknob(fig,'discrete');
%
%   See also UIFIGURE, UIGAUGE, UILAMP, UISLIDER

%   Copyright 2017 The MathWorks, Inc.

styleNames = {...
    'continuous', ...
    'discrete', ...
    };

classNames = {...
    'matlab.ui.control.Knob', ...
    'matlab.ui.control.DiscreteKnob' ...
    };

defaultClassName = 'matlab.ui.control.Knob';

messageCatalogID = 'uiknob';

try
    knobComponent = matlab.ui.control.internal.model.ComponentCreation.createComponentInFamily(...
        styleNames, ...
        classNames, ...
        defaultClassName, ...
        messageCatalogID,...
        varargin{:});
catch ex
      error('MATLAB:ui:Knob:unknownInput', ...
        ex.message);
end