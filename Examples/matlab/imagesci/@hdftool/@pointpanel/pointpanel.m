function this = pointPanel(hdftree, hImportPanel)
%POINTPANEL construct a pointPanel.
%   The pointPanel is responsible for displaying the information of an
%   HDF-EOS POINT.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2005-2013 The MathWorks, Inc.

    this = hdftool.pointpanel;
	titleStr = getString(message('MATLAB:imagesci:hdftool:pointPanelTitle'));
    this.hdfPanelConstruct(hdftree, hImportPanel,titleStr);

    topPanel = uiflowcontainer('v0', 'Parent', this.subsetPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','LeftToRight');

    prefs  = hdftree.fileFrame.prefs;
    
    topLeftPanel = uiflowcontainer('v0', 'Parent',topPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');
    topRightPanel = uiflowcontainer('v0', 'Parent',topPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    
    % Create the 'datafields' uipanel
    [fieldsPanel, this.datafieldApi] = this.createMultilineSelectGroup(...
        topLeftPanel, ...
		getString(message('MATLAB:imagesci:hdftool:dataFields')), {''}, prefs);
    
    % Create the 'Level' uipanel
	titleStr = getString(message('MATLAB:imagesci:hdftool:level'));
    [levelPanel, this.levelApi] = this.createSingleEntryGroup(...
        topLeftPanel, titleStr, '1', prefs);
    
    % RecordNumbers panel
	titleStr = getString(message('MATLAB:imagesci:hdftool:recordOptional'));
    [recordPanel, this.recordApi, minSize] = this.createSingleEntryGroup(...
        topLeftPanel, titleStr, '', prefs);
    
    set(topLeftPanel,...
        'WidthLimits', [minSize(1) minSize(1)]*prefs.charExtent(1));

    % Box panel
    [boxPanel, this.boxApi] = this.createBoxCornerGroup(topRightPanel, '', prefs);

    % Time panel
	titleStr = getString(message('MATLAB:imagesci:hdftool:timeOptional'));
	labelStrings = { getString(message('MATLAB:imagesci:hdftool:labelStrStart')), ...
	                 getString(message('MATLAB:imagesci:hdftool:labelStrStop'))};
    [timePanel, this.timeApi] = this.createEntryFieldGroup(...
        topRightPanel, [1 2], '', labelStrings, titleStr, prefs );
    
end
