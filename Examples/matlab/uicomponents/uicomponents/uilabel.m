function labelComponent = uilabel(varargin)
%UILABEL Create label component 
%   label = UILABEL creates a label component with the text, 'Label', in a
%   new UI figure window and returns a handle to the Label object. 
%
%   label = UILABEL(parent) specifies the object in which to
%   create the label.
%
%   label = UILABEL( ___ ,Name,Value) specifies label properties using one
%   or more Name,Value pair arguments. Use this option with any of the 
%   input argument combinations in the previous syntaxes.
%
%   Example 1: Create a Label Component
%      label = uilabel;
%
%   Example 2: Specify the Parent Object for a Label Component
%      % Specify a UI figure window as the parent object for a label.
%      fig = uifigure;
%      label = uilabel(fig);
%
%   See also UIFIGURE, UIEDITFIELD, UITEXTAREA

%   Copyright 2017 The MathWorks, Inc.


className = 'matlab.ui.control.Label';

messageCatalogID = 'uilabel';

try
    labelComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...
        className, ...
        messageCatalogID,...
        varargin{:});
catch ex
    error('MATLAB:ui:Label:unknownInput', ...
        ex.message);
end