    function component = uidropdown(varargin)
%UIDROPDOWN Create drop-down component
%   dropdown = UIDROPDOWN creates a drop down in a new UI figure window.
%
%   dropdown = UIDROPDOWN(parent) specifies the object in which to create
%   the drop down.
%
%   dropdown = UIDROPDOWN( ___ ,Name,Value) specifies drop down properties
%   using one or more Name,Value pair arguments. Use this option with any 
%   of the input argument combinations in the previous syntaxes. Use the
%   Name,Value pair, Editable,'on' to specify a drop down that allows users
%   to type text into the drop down or select a predefined option.
%
%   Example 1: Create a Drop Down
%      dropdown = uidropdown;
%
%   Example 2: Create an Editable Drop Down
%      dropdown = uidropdown('Editable','on');
%
%   Example 3: Specify the Parent Object for a Drop Down
%      % Specify a small UI figure as the parent object for a drop down.
%      fig = uifigure('Position', [100 100 300 250]);
%      dropdown = uidropdown(fig);
%
%   See also UIFIGURE, UIKNOB, UILISTBOX

%   Copyright 2017 The MathWorks, Inc.



className = 'matlab.ui.control.DropDown';

messageCatalogID = 'uidropdown';

try
    component = matlab.ui.control.internal.model.ComponentCreation.createComponent(...        
        className, ...        
        messageCatalogID,...
        varargin{:});
catch ex
      error('MATLAB:ui:DropDown:unknownInput', ...
        ex.message);
end