function this = rasterPanel(hdftree, hImportPanel)
%RASTERPANEL Construct a rasterPanel.
%   The rasterPanel is responsible for displaying the information of an
%   HDF raster node.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2013 The MathWorks, Inc.

    this = hdftool.rasterpanel;
	titleStr = getString(message('MATLAB:imagesci:hdftool:rasterImagePanelTitle'));
    this.hdfPanelConstruct(hdftree, hImportPanel,titleStr);
    prefs = this.fileTree.fileFrame.prefs;
    
    hParent = uiflowcontainer('v0', 'Parent', this.subsetPanel, ...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','LeftToRight');

    % Create the middle uipanel
	titleStr = getString(message('MATLAB:imagesci:hdftool:colormapVariable'));
    [firstRecPanel, cmapApi] = this.createSingleEntryGroup(...
        hParent, titleStr, 'cmap', prefs);
    
    this.editHandle = findobj(hParent, 'Style', 'Edit');
    this.textHandle = findobj(hParent, 'Style', 'Text');
end
