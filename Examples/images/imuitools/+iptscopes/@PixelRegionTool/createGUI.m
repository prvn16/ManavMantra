function plugInGUI = createGUI(this)
%createGUI Build and cache UI plug-in for PixelRegion plug-in.
%   This adds the button and menu to the scope.
%   No install/render needs to be done here.

%   Copyright 2007-2015 The MathWorks, Inc.

hSrc = this.Application.DataSource;

if isempty(hSrc) || ~isDataLoaded(hSrc)
    enab = 'off';
else
    enab = 'on';
end

mPixel = uimgr.uimenu('PixelRegion', 1, getString(message('images:imtoolUIString:pixelRegionMenubarLabel')));
mPixel.Enable = enab;
mPixel.setWidgetPropertyDefault(...
    'busyaction', 'cancel', ...
    'callback', @(hco, ev) launch(this));

bPixel = uimgr.uipushtool('PixelRegion', 1);
bPixel.IconAppData = 'pixel_region';
bPixel.Enable = enab;
bPixel.setWidgetPropertyDefault(...
    'busyaction', 'cancel', ...
    'tooltip', getString(message('images:imtoolUIString:pixelRegionTooltipString')), ...
    'click',   @(hco, ev) launch(this));

% Create plug-in installer
plan = {mPixel, 'Base/Menus/Tools/VideoTools'; ...
        bPixel, 'Base/Toolbars/Main/Tools/Standard'};
plugInGUI = uimgr.Installer(plan);

% [EOF]