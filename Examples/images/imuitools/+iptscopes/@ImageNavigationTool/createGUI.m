function plugInGUI = createGUI(this)
%CreateGUI Build and cache UI plug-in for IPTZoom plug-in.
%   This adds the button and menu to the scope.
%   No install/render needs to be done here.

%   Copyright 2007-2015 The MathWorks, Inc.

% Do not associate callbacks with menus
% These get sync'd to the buttons, which have the callbacks

% Pan/zoom group plug-in
mZoomIn = uimgr.spctogglemenu('ZoomIn', getString(message('images:commonUIString:zoomInMenubarLabel')));
mZoomIn.setWidgetPropertyDefault(...
    'Callback', @(hcbo, ev) toggle(this, 'ZoomIn'));

mZoomOut = uimgr.spctogglemenu('ZoomOut', getString(message('images:commonUIString:zoomOutMenubarLabel')));
mZoomOut.setWidgetPropertyDefault(...
    'Callback', @(hcbo, ev) toggle(this, 'ZoomOut'));

mPan = uimgr.spctogglemenu('Pan', getString(message('images:commonUIString:panMenubarLabel')));
mPan.setWidgetPropertyDefault(...
    'Callback', @(hcbo, ev) toggle(this, 'Pan'));

mZoomPan = uimgr.uimenugroup('PanZoom', mZoomIn, mZoomOut, mPan);
mZoomPan.SelectionConstraint = 'SelectZeroOrOne';

mMaintain = uimgr.spctogglemenu('Maintain', getString(message('images:implayUIString:maintainFitMenuLabel')));
mMaintain.setWidgetPropertyDefault(...
    'Callback', @(hcbo, ev) toggle(this, 'FitToView'));

mMag = uimgr.uimenugroup('Mag', mMaintain);

% Overall zoom group, position 1 (just after Tools/Standard menu group)
mZoom = uimgr.uimenugroup('Zoom', 1, mZoomPan, mMag);

% Group of Pan/Zoom
b1 = uimgr.uitoggletool('ZoomIn');
b1.IconAppData = 'toggle_zoom_in';
b1.setWidgetPropertyDefault(...
    'tooltip', getString(message('images:commonUIString:zoomInTooltip')), ...
    'busyaction',    'cancel', ...
    'interruptible', 'off', ...
    'click',         @(hco,ev) toggle(this, 'ZoomIn'));

b2 = uimgr.uitoggletool('ZoomOut');
b2.IconAppData = 'toggle_zoom_out';
b2.setWidgetPropertyDefault(...
    'tooltip', getString(message('images:commonUIString:zoomOutTooltip')), ...
    'busyaction',    'cancel', ...
    'interruptible', 'off', ...
    'click',         @(hco,ev) toggle(this, 'ZoomOut'));

b3 = uimgr.uitoggletool('Pan');
b3.IconAppData = 'toggle_pan';
b3.setWidgetPropertyDefault(...
    'tooltip', getString(message('images:implayUIString:panTooltip')) , ...
    'click',   @(hco,ev) toggle(this, 'Pan'));

b4 = uimgr.uitoggletool('Maintain');
b4.IconAppData = 'fit_to_view';
b4.setWidgetPropertyDefault(...
    'tooltip', getString(message('images:implayUIString:maintainFitTooltip')), ...
    'busyaction',    'cancel', ...
    'interruptible', 'off', ...
    'click',         @(hco,ev) toggle(this, 'FitToView'));

bZoomPan = uimgr.uibuttongroup('PanZoom', b1, b2, b3, b4);
bZoomPan.SelectionConstraint = 'SelectZeroOrOne';

% Group of Magnification

if images.internal.isFigureAvailable()
    b5 = uimgr.spcmagcombobox('MagCombo');
    b5.StateName = 'SelectedItem';
    b5.setWidgetPropertyDefault('SelectedItem', ...
        sprintf('%d%%', round(100*get(findProp(this, 'Magnification'), 'Value'))));
    bMag = uimgr.uibuttongroup('Mag', b4, b5);
else
    bMag = uimgr.uibuttongroup('Mag', b4);
end

% Overall zoom group, take position after Standard/Tools
bZoom = uimgr.uibuttongroup('Zoom', bZoomPan, bMag);

% Add state synchronizers
sync2way(mZoomPan, bZoomPan);
sync2way(mMaintain, b4);

% Create plug-in installer
plan = { ...
    mZoom, 'base/Menus/Tools';
    bZoom, 'base/Toolbars/Main/Tools'};
plugInGUI = uimgr.Installer(plan);

% -------------------------------------------------------------------------
function toggle(this, mode)

% If we are toggling the current mode, then turn it off.  Otherwise, set
% the current mode to what we are toggling.
if strcmpi(mode, this.Mode)
    this.Mode = 'off';
else
    this.Mode = mode;
end

% [EOF]