function buttonComponent = uibutton(varargin)
%UIBUTTON Create push button or state button component
%   button = UIBUTTON creates a push button in a new UI figure window.
%
%   button = UIBUTTON(style) creates a button of the specified style.
%
%   button = UIBUTTON(parent) specifies the object in which to create the 
%   button.
%
%   button = UIBUTTON(parent,style) creates a button of the specified style
%   in the specified parent object.
%
%   button = UIBUTTON( ___ ,Name,Value) specifies button properties using 
%   one or more Name,Value pair arguments. Use this option with any of the
%   input argument combinations in the previous syntaxes.
%
%   Example 1: Create a Button
%      % Create a push button, the default style for a button.
%      button = uibutton;
%
%   Example 2: Create a State Button
%      % Create a state button by specifying the style as state.
%      button = uibutton('state');
%
%   Example 3: Specify the Parent Object for a Push Button
%      % Create a UI figure window containing a button and a panel. 
%      % Specify the panel as the parent for the button.
%      fig = uifigure('Name','My Figure');
%      panel = uipanel(fig);
%      button = uibutton(panel);
%
%   See also UIFIGURE, UITOGGLEBUTTON, UICHECKBOX 

%   Copyright 2017 The MathWorks, Inc.

styleNames = { ...
    'push',...
    'state',...
    };

classNames = {...
    'matlab.ui.control.Button', ...
    'matlab.ui.control.StateButton' ...
    };

defaultClassName = 'matlab.ui.control.Button';

messageCatalogID = 'uibutton';

try
    buttonComponent = matlab.ui.control.internal.model.ComponentCreation.createComponentInFamily(...
        styleNames, ...
        classNames, ...
        defaultClassName, ...
        messageCatalogID,...
        varargin{:});        
catch ex
    error('MATLAB:ui:Button:unknownInput', ...
        ex.message);
end
