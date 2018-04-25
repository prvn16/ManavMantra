function onToolsMenuOpening(this, ~, ~)
%ONTOOLSMENUOPENING Define the ONTOOLSMENUOPENING class.
%   OUT = ONTOOLSMENUOPENING(ARGS) <long description>

%   Copyright 2016-2017 The MathWorks, Inc.

if this.ColorMap.IsIntensity
    ena = 'on';
else
    ena = 'off';
end
source = this.Application.DataSource;
if isempty(source) || isDataEmpty(source)
    ena = 'off';
end

hUIMgr = this.Application.getGUI;
if isempty(hUIMgr)
    set(this.ColormapMenu, 'Enable', ena);
else
    set(hUIMgr.findchild( 'Menus', 'Tools', 'VideoTools', 'Colormap' ), 'Enable', ena);
end

% [EOF]
