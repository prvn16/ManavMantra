function textAreaComponent = uitextarea(varargin)
%UITEXTAREA Create text area component 
%   textarea = UITEXTAREA creates a text area in a new UI figure window.
%
%   textarea = UITEXTAREA(parent) specifies the object in which to create
%   the text area. 
%
%   textarea = UITEXTAREA( ___ ,Name,Value) specifies text area properties
%   using one or more Name,Value pair arguments. Use this option with any
%   of the input argument combinations in the previous syntaxes.
%
%   Example 1: Create Text Area
%      textarea = uitextarea;
%
%   Example 2: Specify the Parent Object for a Text Area
%      % Specify a small UI figure window as the parent object
%      % for a text area. 
%      fig = uifigure('Position', [100 100 429 276])
%      textarea = uitextarea(fig);
%
%   See also UIFIGURE, UIEDITFIELD, UILABEL

%   Copyright 2017 The MathWorks, Inc.

className = 'matlab.ui.control.TextArea';

messageCatalogID = 'uitextarea';

try
    textAreaComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...        
        className, ...
        messageCatalogID,...
        varargin{:});    
   
catch ex
    error('MATLAB:ui:TextArea:unknownInput', ...
        ex.message);
end
