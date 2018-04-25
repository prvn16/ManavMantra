function radioButtonComponent = uiradiobutton(varargin)
%UIRADIOBUTTON Create radio button component
%   radiobutton = UIRADIOBUTTON(parent) creates a radio button within the
%   specified button group.
%
%   radiobutton = UIRADIOBUTTON(parent,Name,Value) specifies radio button
%   properties using one or more Name,Value pair arguments.
%
%   Example: Create Radio Buttons Within a Button Group and Access Property Values
%      % To create a radio button, first create a UI figure window and a
%      button group object.
%      fig = uifigure('Position',[680 678 398 271]);
%      bg = uibuttongroup(fig,'Position',[137 113 123 85]);
%
%      % Create three radio buttons and specify the location of each.
%      rb1 = uiradiobutton(bg,'Position',[10,60 91 15]);
%      rb2 = uiradiobutton(bg,'Position',[10,38 91 15]);
%      rb3 = uiradiobutton(bg,'Position',[10,16 91 15]);
%
%      % Change the text associated with each radio button.
%      rb1.Text = 'English';
%      rb2.Text = 'French';
%      rb3.Text = 'German';
%
%      % Change the radio button selection to German.
%      rb3.Value = true;
%
%   See also UIFIGURE, UIBUTTONGROUP, UISWITCH, UITOGGLEBUTTON

%   Copyright 2017 The MathWorks, Inc.

className = 'matlab.ui.control.RadioButton';

messageCatalogID = 'uiradiobutton';

try
    radioButtonComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...
        className, ...
        messageCatalogID,...
        varargin{:});
catch ex
    
    % Customize invalid parent message because uiradiobutton has restricted
    % parenting; the shared message is not accurate
    if strcmp(ex.identifier, 'MATLAB:ui:uiradiobutton:invalidParent')
        
        messageObj = message('MATLAB:ui:components:invalidClass', ...
            'Parent', 'ButtonGroup');
        
        % Use string from object
        messageText = getString(messageObj);
        
    else
        messageText = ex.message;
        
    end
    
    error('MATLAB:ui:RadioButton:unknownInput', ...
        messageText);
end