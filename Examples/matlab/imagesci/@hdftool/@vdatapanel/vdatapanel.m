function this = vdataPanel(hdftree, hImportPanel)
%VDATAPANEL Construct a vdataPanel.
%   The vdataPanel is responsible for displaying the information of an
%   HDF vdata node.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2013 The MathWorks, Inc.

    this = hdftool.vdatapanel;
	titleStr = getString(message('MATLAB:imagesci:hdftool:vdataPanelTitle'));
    this.hdfPanelConstruct(hdftree, hImportPanel, titleStr);

    hParent = uiflowcontainer('v0', 'Parent', this.subsetPanel,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection', 'TopDown');

    prefs  = hdftree.fileFrame.prefs;

    % Create the top uipanel
    [fieldsPanel, this.datafieldApi] = this.createMultilineSelectGroup(...
        hParent, ...
		getString(message('MATLAB:imagesci:hdftool:dataFields')), {''}, prefs);

    % Create the middle uipanel
	titleStr = getString(message('MATLAB:imagesci:hdftool:firstRecord'));
    [firstRecPanel, this.firstRecordApi] = this.createSingleEntryGroup(...
        hParent, titleStr, '1', prefs);

    % Create the bottom uipanel
	titleStr = getString(message('MATLAB:imagesci:hdftool:numRecords'));
    [numRecPanel, this.numRecordsApi] = this.createSingleEntryGroup(...
        hParent, titleStr, '', prefs);

end



