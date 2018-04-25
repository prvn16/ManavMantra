function datePickerComponent = uidatepicker(varargin)
%UIDATEPICKER Create date picker component
%   d = UIDATEPICKER creates a date picker in a new figure and returns the
%   DatePicker object. MATLAB calls the uifigure function to create the figure.
%
%   d = uidatepicker(Name,Value) specifies DatePicker property values using
%   one or more Name,Value pair arguments.
%
%   d = uidatepicker(parent) creates a date picker in the specified parent
%   container. The parent container can be a figure created using the
%   uifigure function, or one of its child containers: Tab, Panel, or ButtonGroup.
%
%   d = uidatepicker(parent,Name,Value) creates the date picker in the
%   specified container and sets one or more DatePicker property values.
%
%   Example 1: Create a date picker
%      fig = uifigure;
%      d = uidatepicker(fig);
%
%   Example 2: Set initial value for date picker
%      fig = uifigure;
%      d = uidatepicker(fig);
%      d.Value = datetime('today');
%
%   Example 3: Disable weekends in the date picker
%      fig = uifigure;
%      d = uidatepicker(fig);
%      d.DisabledDaysOfWeek = [1, 7];
%
%   See also UIFIGURE, DATETIME 

%   Copyright 2017 The MathWorks, Inc.

className = 'matlab.ui.control.DatePicker';

messageCatalogID = 'uidatepicker';

try
    datePickerComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...       
        className, ...
        messageCatalogID,...
        varargin{:});        
catch exc
    error('MATLAB:ui:DatePicker:unknownInput', ...
        exc.message);
end
