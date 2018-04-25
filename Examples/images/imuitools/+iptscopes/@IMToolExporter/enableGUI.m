function enableGUI(this, enabState)
%ENABLEGUI Enable/disable the UI widgets.

%   Copyright 2007-2017 The MathWorks, Inc.

hui = getGUI(this.Application);
if isempty(hui)
    set([this.IMToolExporterMenu this.IMToolExporterButton], ...
        'Enable', enabState);
else
    set(hui.findchild('Base/Menus/File/Export/IMToolExporter'), 'Enable', enabState);
    set(hui.findchild('Base/Toolbars/Main/Export/IMToolExporter'), 'Enable', enabState);
end

% [EOF]