function renderMenus(this)

% Copyright 2017 The MathWorks, Inc.

this.IMToolExporterMenu = uimenu( ...
    this.Application.Handles.fileMenu, ...
    'Tag','uimgr.uimenu_IMToolExporter', ...
    'Label', getString(message('images:implayUIString:exportToImageToolMenuLabel')), ...
    'BusyAction', 'cancel', ...
    'Separator', 'on', ...
    'Accelerator', 'e', ...
    'Callback', @(hco,ev) lclExport(this));

enabState = get(this.IMToolExporterButton,'Enable');
if ~isempty(enabState)
    set(this.IMToolExporterMenu,'Enable',enabState)
end

% Place it right below the Configuration menu item
anchorMenu = findobj(this.Application.Parent, 'Tag', 'uimgr.uimenugroup_Configs');
% When Configuration Set Edit/Load/Save is disabled,
% the uimenugroup becomes a uimenu
if isempty(anchorMenu)
    anchorMenu = findobj(this.Application.Parent, 'Tag', 'uimgr.uimenu_Configs');
end
if ~isempty(anchorMenu)
    this.IMToolExporterMenu.Position = get(anchorMenu,'Position') + 1;
end
