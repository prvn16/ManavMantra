function [hTileFrame, api] = createTileFrame(this, hParent)
%CREATETILEFRAME Construct a frame for the "TILE" subsetting method.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   HPARENT: the panel which will be our HG parent.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Create the components.
    hTileFrame = uipanel('Parent', hParent);
    prefs = this.fileTree.fileFrame.prefs;
    topPanel = uiflowcontainer('v0', 'Parent', hTileFrame,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection', 'TopDown');

    % Create the 'Tile' panel
	titleStr = getString(message('MATLAB:imagesci:hdftool:tileCoordinates'));
    [levelPanel, api, minSize] = this.createSingleEntryGroup(...
        topPanel, titleStr, '1,1', prefs);

end

