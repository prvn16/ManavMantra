function this = gridpanel(hdftree, hImportPanel)
%GRIDPANEL Construct a gridpanel.
%   The gridpanel is responsible for displaying the information of an
%   HDF-EOS GRID.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2013 The MathWorks, Inc.

    % Create the components.
    this = hdftool.gridpanel;
	titleStr = getString(message('MATLAB:imagesci:hdftool:gridPanelTitle'));
    this.hdfPanelConstruct(hdftree, hImportPanel,titleStr);

    hPanel = this.subsetPanel;
    topPanel = uipanel('Parent', hPanel);
    topPanel = uiflowcontainer('v0', 'Parent',topPanel,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    % Create the subset selection panel
    names = {getString(message('MATLAB:imagesci:hdftool:noSubsetting')),...
        getString(message('MATLAB:imagesci:hdftool:directIndex')),...
        getString(message('MATLAB:imagesci:hdftool:geographicBox')),...
        getString(message('MATLAB:imagesci:hdftool:interpolate')),...
        getString(message('MATLAB:imagesci:hdftool:pixels')),...
        getString(message('MATLAB:imagesci:hdftool:tile')),...
        getString(message('MATLAB:imagesci:hdftool:time')),...
        getString(message('MATLAB:imagesci:hdftool:userdefined'))};

    [radioBtns, api, ctrls] = makePopupMenu(this, topPanel, @createFrame, ...
        names, this.fileTree.fileFrame.prefs);

    % Store the API's.
    this.subsetSelectionApi = api;
    this.subsetApi{8} = [];
    this.subsetFrameContainer = topPanel;
    [this.subsetFrame(1), this.subsetApi{1}] = createEmptyFrame(this, this.subsetFrameContainer);

    % Since we have no parameters, disable the reset button.
    resetButton = findobj(this.mainPanel, 'tag', 'resetSelectionParameters');
    set(resetButton, 'enable', 'off');
end


function createFrame(this, index)
    % This method is called when a radio button (corresponding to a 
    % different selection method) is pressed.
    
    % If we have already created the panel, return.
    if ~isempty(this.subsetApi{index})
        return
    end

    % Since we have no parameters, disable the reset button.
    resetButton = findobj(this.mainPanel, 'tag', 'resetSelectionParameters');
    if index == 1
        set(resetButton, 'enable', 'off');
    else
        set(resetButton, 'enable', 'on');
    end
    
    % Create the appropriate panel.
    switch index
        case 1
            [this.subsetFrame(1), this.subsetApi{1}] = createEmptyFrame(this, this.subsetFrameContainer);
        case 2
            [this.subsetFrame(2), this.subsetApi{2}] = createDirectIndexFrame(this, this.subsetFrameContainer);
        case 3
            [this.subsetFrame(3), this.subsetApi{3}] = createGeographicBoxFrame(this, this.subsetFrameContainer);
        case 4
            [this.subsetFrame(4), this.subsetApi{4}] = createInterpolateFrame(this, this.subsetFrameContainer);
        case 5
            [this.subsetFrame(5), this.subsetApi{5}] = createPixelsFrame(this, this.subsetFrameContainer);
        case 6
            [this.subsetFrame(6), this.subsetApi{6}] = createTileFrame(this, this.subsetFrameContainer);
        case 7
            [this.subsetFrame(7), this.subsetApi{7}] = createTimeFrame(this, this.subsetFrameContainer);
        case 8
            [this.subsetFrame(8), this.subsetApi{8}] = createUserDefinedFrame(this, this.subsetFrameContainer);
    end
end

