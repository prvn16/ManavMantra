function this = filepanel(hImportPanel)
%FILEPANEL Construct a default filepanel object.
%   All that this panel will do is display a text string.
%   It is used for objects which do not necessitate a fully-specialized
%   panel, but only wish to display brief textual information.
%
%   Function arguments
%   ------------------
%   HIMPORTPANEL: The HG parent of this panel.

%   Copyright 2005-2013 The MathWorks, Inc.

    this = hdftool.filepanel;

    this.mainpanel = uipanel('Parent', hImportPanel,...
        'Title', '');
    subsetPanelContainer = uigridcontainer('v0', 'Parent',this.mainpanel);

    noDataLabel = uicontrol('Parent',subsetPanelContainer,...
        'Style','Text',...
        'String','',...
        'FontSize', 3 + get(hImportPanel, 'defaultUicontrolFontSize'),...
        'FontWeight', 'bold');

    labelExtent = get(noDataLabel,'Extent');
    set(noDataLabel, 'Position', labelExtent);

end
