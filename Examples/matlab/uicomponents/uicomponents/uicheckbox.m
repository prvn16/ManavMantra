function checkBoxComponent = uicheckbox(varargin)
%UICHECKBOX Create check box component
%   checkbox = UICHECKBOX creates a check box in a new UI figure window.
%
%   checkbox = UICHECKBOX(parent) specifies the object in which to create 
%   the check box.
%
%   checkbox = UICHECKBOX( ___ ,Name,Value) specifies check box properties
%   using one or more Name,Value pair arguments. Use this option with any
%   of the input argument combinations in the previous syntaxes.
%
%   Example 1: Create Check Box
%      checkbox = uicheckbox;
%      % Specify the Parent Object for a Check Box
%      fig = uifigure;
%      checkbox = uicheckbox(fig);
%
%   See also UIFIGURE, UIBUTTON, UIRADIOBUTTON,  UISWITCH, UITOGGLEBUTTON 

%   Copyright 2017 The MathWorks, Inc.

className = 'matlab.ui.control.CheckBox';

messageCatalogID = 'uicheckbox';

try
    checkBoxComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...       
        className, ...
        messageCatalogID,...
        varargin{:});        
catch exc
    error('MATLAB:ui:CheckBox:unknownInput', ...
        exc.message);
end
