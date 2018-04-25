function enableGUI(this, event)
%ENABLEGUI Enable/Disable GUI items

%   Copyright 2010-2017 The MathWorks, Inc.


hSource = this.Application.DataSource;
if isempty(hSource) || ~(hSource.isDataLoaded)
    ena = 'off';
else
    ena = 'on';
end
hUIMgr = this.Application.getGUI;
hDialogMenu = hUIMgr.findchild('Menus','View','DialogPanelMenu');
set(hDialogMenu,'Enable',ena);

hFreqMenu = hUIMgr.findchild('Menus','View','VerticalUnits');
set(hFreqMenu,'Enable',ena);

% Since the outerposition of the Application is fixed, installing a toolbar
% will not resize the figure wondow. We need to manually resize the panels
% in the dialog presenter to adjust for the space taken up by the toolbar.
resizeVisualForToolbarInstall(this.NTExplorerObj);

%-------------------------------------------------------------------
% [EOF]
