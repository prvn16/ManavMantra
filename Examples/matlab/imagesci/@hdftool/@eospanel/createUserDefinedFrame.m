function [hFrame, api, panel] = createUserDefinedFrame(this, hParent)
%CREATEUSERDEFINEDFRAME Creates the uipanels for "user-defined" subsetting method.
%   The UI controls correspond to list boxes to select the dimension,
%   and two edit boxes which specify the minimum and maximum values.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent for the frame.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Create the components.
    hFrame = uipanel('Parent', hParent);
    prefs = this.fileTree.fileFrame.prefs;
    panel = uiflowcontainer('v0', 'Parent',hFrame,...
                'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
                'FlowDirection','LeftToRight');

	titleString = getString(message('MATLAB:imagesci:hdftool:userdefined'));
    [userdefPanel, userdefApi, minSize] = this.createUserDefinedGroup(panel, '', titleString, prefs);

    % Create the API
    api.updateUserDefPanel = @updateUserDefinedPanel;
    api.getUserDefined     = @getUserDefined;
    api.reset              = @reset;

    %===========================================================
    function updateUserDefinedPanel(istruct)

        if userdefApi.getLength() == length(istruct.Dims)
            userdefApi.setInfoStruct(istruct);
            return;
        end

		titleString = getString(message('MATLAB:imagesci:hdftool:userdefined'));
        [newPanel, userdefApi, minSize] = this.createUserDefinedGroup(panel, '', titleString, prefs);
        delete(userdefPanel);
        userdefPanel = newPanel;
    end

    %=======================================================
    function out = getUserDefined()
        selFields = userdefApi.getSelectedFieldNames();
        minVals   = userdefApi.getMinValues();
        maxVals   = userdefApi.getMaxValues();

        out = [selFields, minVals, maxVals];
    end

    %==================================
    function reset(istruct)
        userdefApi.reset();
        if nargin == 1
            updateUserDefinedPanel(istruct);
        end
    end
end


