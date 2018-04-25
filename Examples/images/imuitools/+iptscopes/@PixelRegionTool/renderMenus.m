function renderMenus(this)

% Copyright 2017 The MathWorks, Inc.

hSrc = this.Application.DataSource;
if isempty(hSrc) || ~isDataLoaded(hSrc)
    enab = 'off';
else
    enab = 'on';
end

this.PixelRegionMenu = uimenu( ...
    this.Application.Handles.toolsMenu, ...
    'Tag','uimgr.uimenu_PixelRegion', ...
    'Label', getString(message('images:imtoolUIString:pixelRegionMenubarLabel')), ...
    'BusyAction', 'cancel', ...
    'Callback', @(hco,ev) launch(this), ...
    'Enable', enab);

% Place it right below the Video Information menu item, if it exists
videoInfoMenu = findobj(this.Application.Parent, 'Tag', 'uimgr.uimenu_VideoInfo');
if ~isempty(videoInfoMenu)
    this.PixelRegionMenu.Position = get(videoInfoMenu,'Position') + 1;
end
