function initializePreferences(this, fig)
%INITIALIZEPREFERENCES Define several static properties of the UI.
%   This method is called to initialize the preferences when
%   the tool is started.  Most of the sizes are in character units.
%
%   Function arguments
%   ------------------
%   THIS: the object instance
%   FIG: the figure

%   Copyright 2005-2015 The MathWorks, Inc.

    prefs.toolTitle = getString(message('MATLAB:imagesci:hdftool:toolTitle'));

    % Set defaults for all frame positioning information
    prefs.minPanelWidth     = 120;
    prefs.minPanelHeight    =  34;
    prefs.minTreeWidth      =  10;
    prefs.minMetadataHeight =   2;
    prefs.minFigureSize = [prefs.minPanelWidth+prefs.minTreeWidth ...
                           prefs.minPanelHeight+prefs.minMetadataHeight];

    defaultFigSize = [160 45];
    % Get the screensize in characters.
    screenSize = hgconvertunits(fig, get(0,'ScreenSize'), get(0,'Units'), 'characters', 0);
    screenSize = screenSize(3:4);
    defaultRect = [(screenSize*0.5 - defaultFigSize*0.5) defaultFigSize];

    % Get the default figure size.
    prefs.figurePosition = getpref('MATLAB_IMAGESCI', 'FILETOOL_SIZE', defaultRect);
    prefs.figurePosition(3:4) = max(prefs.figurePosition(3:4), prefs.minFigureSize);
    minPanelSize = [prefs.minPanelWidth prefs.minPanelHeight];
    panelSize = getpref('MATLAB_IMAGESCI', 'FILETOOL_CONFIG_SIZE', minPanelSize);
    panelSize = max(panelSize, minPanelSize);
    prefs.panelWidth  = panelSize(1);
    prefs.panelHeight = panelSize(2);

    prefs.confirmClose = getpref('MATLAB_IMAGESCI', 'CLOSE_CONFIRMATION', false);
    prefs.confirmImport = getpref('MATLAB_IMAGESCI', 'IMPORT_CONFIRMATION', false);
    prefs.dividerWidth = [1.5 0.5];

    % Set the layout defaults
    %======================================================================

    set(fig, 'DefaultUicontrolUnits', 'Characters');
    set(fig, 'defaultUiflowcontainerMargin', 1);
    set(fig, 'defaultUipanelTitlePosition', 'lefttop');
    set(fig, 'DefaultUipanelBordertype', 'none');
    set(fig, 'DefaultUipanelUnits', 'normalized');
    set(fig, 'DefaultUipanelPosition', [0 0 1 1]);

    % Set the GUI preferences
    %======================================================================

    % Padding in between uicontrols, specified in pixels.
    prefs.pad = 10;

    % left (text) width for "text:edit" controls.
    prefs.subsetPanelContainer.leftWidth = 25;
    % right (edit) width for "text:edit" controls.
    prefs.subsetPanelContainer.rightWidth = 20;

    % uipanels take up space for the title and the border.
    prefs.uipanelBorderHeight = 1.0;
    prefs.uipanelBorderWidth = 1.0;

    % Setup the color preferences.  
	bgColorObj = com.mathworks.services.ColorPrefs.getBackgroundColor();
	r = get(bgColorObj,'Red');
	g = get(bgColorObj,'Green');
	b = get(bgColorObj,'Blue');
    prefs.colorPrefs.backgroundColor = [r g b]/255;
    prefs.colorPrefs.backgroundColorObj = bgColorObj;

	textColorObj = com.mathworks.services.ColorPrefs.getTextColor();
	r = get(textColorObj,'Red');
	g = get(textColorObj,'Green');
	b = get(textColorObj,'Blue');
    prefs.colorPrefs.textColor = [r g b]/255;
    prefs.colorPrefs.textColorObj = textColorObj;

	p = get(0,'defaultUicontrolBackgroundColor');
	if isequal(p,[0 0 0])
    	prefs.colorPrefs.menuTextColor = [1 1 1];
	else
    	prefs.colorPrefs.menuTextColor = [0 0 0];
	end
    

    % Sizes of various controls
    prefs.charBtnHeight   =  1.6;
    prefs.charBtnWidth    = 18.0;
    prefs.charTextHeight  =  1.0;
    prefs.charRadioHeight =  1.2;
    % The width for numeric-entry text edit fields.
    prefs.charEditWidth   = 12;
    % pixels taken up by the 'button' of a radio button
    prefs.radioButtonWidth = 20;

    % Additional Y offset to text on the left side of a pushbutton
    prefs.charLabelOffset = (prefs.charBtnHeight-prefs.charTextHeight)/2;

    % Find out the size (in pixels) of a character.
    prefs.charExtent = hgconvertunits(fig, [0 0 1 1], 'character', 'pixel', 0);
    prefs.charExtent = prefs.charExtent(3:4);

    % The following measurements are in character units.
    prefs.charPad = [prefs.pad/prefs.charExtent(1) prefs.pad/prefs.charExtent(2)];
    prefs.btnWidth  = prefs.charBtnWidth * prefs.charExtent(1);
    prefs.btnHeight = prefs.charBtnHeight * prefs.charExtent(2);
    this.prefs = prefs;

end

