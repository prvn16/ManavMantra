function this = swathPanel(hdftree, hImportPanel)
%SWATHPANEL construct a swathPanel.
%   The swathPanel is responsible for displaying the information of an
%   HDF-EOS SWATH.
%
%   Function arguments
%   ------------------
%   HDFTREE: the hdfTree which contains us.
%   HIMPORTPANEL: the panel which will be our HG parent.

%   Copyright 2004-2013 The MathWorks, Inc.

    this = hdftool.swathpanel;
	titleStr = getString(message('MATLAB:imagesci:hdftool:swathPanelTitle'));
    this.hdfPanelConstruct(hdftree, hImportPanel,titleStr);
    hPanel = this.subsetPanel;

    topPanel = uipanel('Parent',hPanel);
    topPanel = uiflowcontainer('v0', 'Parent',topPanel,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    buttonNames = {getString(message('MATLAB:imagesci:hdftool:noSubsetting')),...
        getString(message('MATLAB:imagesci:hdftool:directIndex')),...
        getString(message('MATLAB:imagesci:hdftool:geographicBox')),...
        getString(message('MATLAB:imagesci:hdftool:time')),...
        getString(message('MATLAB:imagesci:hdftool:userdefined'))};

    [radioBtns, api, ctrl] = makePopupMenu(this, topPanel, @createFrame, ...
        buttonNames, this.fileTree.fileFrame.prefs);
    this.subsetSelectionApi = api;
    this.subsetApi{5} = [];
    this.subsetFrameContainer = topPanel;
    [this.subsetFrame(1), this.subsetApi{1}] = createEmptyFrame(this, this.subsetFrameContainer);

end


function createFrame(this, index)
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
            [this.subsetFrame(2), this.subsetApi{2}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'DirectIndex');
        case 3
            [this.subsetFrame(3), this.subsetApi{3}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'GeographicBox');
        case 4
            [this.subsetFrame(4), this.subsetApi{4}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'Time');
        case 5
            [this.subsetFrame(5), this.subsetApi{5}] = createModeAugmentedFrame(this, this.subsetFrameContainer, 'UserDefined');
    end
end

