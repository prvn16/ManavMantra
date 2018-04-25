function installDefaultUserSettings(ntx)
% Default settings for all user-settable properties.
% 
% Only need to address defaults for child objects (objects contained within
% NTX) that are not specific to NTX and therefore may have defaults that
% are not appropriate for NTX.

%   Copyright 2010-2012 The MathWorks, Inc.

% Install defaults for DialogPanel child object
dp = ntx.dp;
dp.AutoHide   = false;
dp.PanelLock  = false;
dp.PanelWidth = 189 * dp.PixelFactor; %168; % initial width of DPVerticalPanel, in pixels

% Ordered list of names of visible dialogs
dp.DockedDialogNamesInit = { ...
    getString(message('fixed:NumericTypeScope:LegendDialogName')),        ...
    getString(message('fixed:NumericTypeScope:ResultingTypeDialogName')), ...
    getString(message('fixed:NumericTypeScope:BitAllocationDialogName')), ...
    getString(message('fixed:NumericTypeScope:InputDataDialogName')) };
