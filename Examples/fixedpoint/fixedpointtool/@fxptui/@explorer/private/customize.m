function h = customize(h)
%CUSTOMIZE   

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.

% product title should not be translated/localized. 
h.title = fxptui.message('titleFPTool');
h.setTreeTitle(fxptui.message('labelModelHierarchy'));
%get im explorer and save it for later use 
h.imme = DAStudio.imExplorer(h);
%set the wait property as true. 
h.delaySleepWake = true;
h.showDialogView(true);
h.showContentsOf(true);
h.showFilterContents(false);
h.setListMultiSelect(false);
h.GroupingEnabled = true;
h.setStatusMessage(fxptui.message('labelFPTInitialize'));
set_param(0, 'HiliteAncestorsData', fxptui.gethilitescheme);

% [EOF]
