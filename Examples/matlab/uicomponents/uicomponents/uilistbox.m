function listBoxComponent = uilistbox(varargin)
%UILISTBOX Create list box component
%   listbox = UILISTBOX creates a list box in a new UI figure window.
%
%   listbox = UILISTBOX(parent) specifies the object in which to create
%   the list box.
%
%   listbox = UILISTBOX( ___ ,Name,Value) specifies list box properties
%   using one or more Name,Value pair arguments. Use this option with any 
%   of the input argument combinations in the previous syntaxes.
%
%   Example 1: Create a List Box
%      listbox = uilistbox;
%
%   Example 2: Specify the Parent Object for a List Box
%      % Specify a small UI figure window
%      % as the parent object for a listbox.
%      fig = uifigure('Position', [100 100 300 250]);
%      listbox = uilistbox(fig);
%
%   Example 3: Enable multiselection
%      % Create a default list box
%      listbox = uilistbox;
%      % Enable multiselection
%      listbox.MultiSelect = 'on';
%
%   See also UIFIGURE, UIDROPDOWN, UIKNOB

%   Copyright 2017 The MathWorks, Inc.


className = 'matlab.ui.control.ListBox';

messageCatalogID = 'uilistbox';

try
    listBoxComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...        
        className, ...
        messageCatalogID,...        
        varargin{:});
catch ex
      error('MATLAB:ui:ListBox:unknownInput', ...
        ex.message);
end