function toggleButtonComponent = uitogglebutton(varargin)
%UITOGGLEBUTTON Create toggle button component
%   togglebutton = UITOGGLEBUTTON(parent) creates a toggle button within
%   the specified parent button group.
%
%   togglebutton = UITOGGLEBUTTON(parent,Name,Value) specifies toggle
%   button properties using one or more Name,Value pair arguments.
%
%   Example: Create Toggle Buttons and Access Property Values
%      % To create toggle buttons, first create a UI figure window
%      % and a button group object.
%      fig = uifigure('Position',[680 678 398 271]);
%      bg = uibuttongroup(fig,'Position',[137 113 123 85]);
%
%      % Create three toggle buttons and specify the location of each.
%      tb1 = uitogglebutton(bg,'Position',[10 50 100 20]);
%      tb2 = uitogglebutton(bg,'Position',[10 28 100 20]);
%      tb3 = uitogglebutton(bg,'Position',[10 6 100 20]);
%
%      % Change the text associated with each toggle button.
%      tb1.Text = 'English';
%      tb2.Text = 'French';
%      tb3.Text = 'German';
%
%      % Change the toggle button selection to German programmatically.
%      tb3.Value = true;
%
%   See also UIFIGURE, UIBUTTON, UIBUTTONGROUP, UICHECKBOX, UIRADIOBUTTON, UISWITCH

%   Copyright 2017 The MathWorks, Inc.


className = 'matlab.ui.control.ToggleButton';

messageCatalogID = 'uitogglebutton';

try
    toggleButtonComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...
        className, ...
        messageCatalogID,...
        varargin{:});
catch ex
    
    % Customize invalid parent message because uitogglebutton has restricted
    % parenting; the shared message is not accurate
    if strcmp(ex.identifier, 'MATLAB:ui:uitogglebutton:invalidParent')
        
        messageObj = message('MATLAB:ui:components:invalidClass', ...
            'Parent', 'ButtonGroup');
        
        % Use string from object
        messageText = getString(messageObj);
        
    else
        messageText = ex.message;
        
    end
    
    error('MATLAB:ui:ToggleButton:unknownInput', ...
        messageText);
end