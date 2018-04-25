function [hFrame, api, leftPanel] = createTimeFrame(this, hParent, additionalGroupCB)
%CREATETIMEFRAME Creates the uipanels for "time" subsetting method.
%   The UI controls (text edit fields) correspond to a start and an
%   end time.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent for the frame.
%   ADDITIONALGROUPCB: Callback to add a group to our layout.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Create the components.
    hFrame = uipanel('Parent', hParent);
    prefs = this.fileTree.fileFrame.prefs;
    
    topPanel = uiflowcontainer('v0', 'Parent',hFrame,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','LeftToRight');
    leftPanel = uiflowcontainer('v0', 'Parent',topPanel,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    if nargin >= 3
        additionalGroupCB(leftPanel);
    end

	titleStr = getString(message('MATLAB:imagesci:hdftool:time'));
	labelStrings = { getString(message('MATLAB:imagesci:hdftool:labelStrStart')), ...
	                 getString(message('MATLAB:imagesci:hdftool:labelStrStop'))};
    [timePanel, timeApi, tSize] = this.createEntryFieldGroup(leftPanel, [1 2], '0', ...
	    labelStrings, titleStr, prefs );

    if nargin < 3    
        width  = prefs.charPad(1) + tSize(1);
        height = prefs.charPad(2) + tSize(2);
    else
        sizeLimits = get(leftPanel, {'WidthLimits','HeightLimits'});
        width  = prefs.charPad(1) + max(tSize(1), sizeLimits{1}(1));
        height = prefs.charPad(2) + tSize(2) + sizeLimits{2}(1);
    end

    set(leftPanel, 'WidthLimits', [width width],...
        'HeightLimits', [height height]);

	displayedTitle = getString(message('MATLAB:imagesci:hdftool:userdefinedOptional'));
    [userdefPanel, userdefApi, uminSize] = this.createUserDefinedGroup(topPanel, '', displayedTitle, prefs);

    % Create the API
    api.reset              = @reset;
    api.getTime            = @getTime;
    api.getUserDefined     = @getUserDefined;
    api.updateUserDefPanel = @updateUserDefinedPanel;

    %===========================================================
    function updateUserDefinedPanel(istruct)

        if userdefApi.getLength() == length(istruct.Dims)
            userdefApi.setInfoStruct(istruct);
            return;
        end

		displayedTitle = getString(message('MATLAB:imagesci:hdftool:userdefinedOptional'));
        [newPanel, userdefApi, uminSize] = this.createUserDefinedGroup(topPanel, '', displayedTitle, prefs);
        delete(userdefPanel);
        userdefPanel = newPanel;
    end

    %==================================
    function out = getTime()
        out = timeApi.getValues()';
    end

    %==================================
    function out = getUserDefined()
        selFields = userdefApi.getSelectedFieldNames();
        minVals   = userdefApi.getMinValues();
        maxVals   = userdefApi.getMaxValues();

        out = [selFields, minVals, maxVals];
    end

    %==================================
    function reset(istruct)
        timeApi.reset();
        userdefApi.reset();
        if nargin == 1
            updateUserDefinedPanel(istruct);
        end
    end
end
