function lampComponent = uilamp(varargin)
%UILAMP Create lamp component 
%   lamp = UILAMP creates a lamp component in a new UI figure window.
%
%   lamp = UILAMP(parent) specifies the object in which to create the lamp.
%
%   lamp = UILAMP( ___ ,Name,Value) specifies lamp properties using one or
%   more Name,Value pair arguments. Use this option with any of the input
%   argument combinations in the previous syntaxes.
%
%   Example 1: Create a Default Lamp Component
%      % The default lamp component is green.
%      lamp = uilamp;
%
%   Example 2: Specify the Parent Object for a Lamp Component
%      % Specify a UI figure window as the parent object for a lamp.
%      fig = uifigure;
%      lamp = uilamp(fig);
%
%   See also UIFIGURE, UIGAUGE, UIKNOB, UISWITCH

%   Copyright 2017 The MathWorks, Inc.


className = 'matlab.ui.control.Lamp';

messageCatalogID = 'uilamp';

try
    lampComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...        
        className, ...
        messageCatalogID,...        
        varargin{:});
catch ex
      error('MATLAB:ui:Lamp:unknownInput', ...
        ex.message);
end