function enable(this)
%ENABLE   Enable the extension.

%   Copyright 2007-2017 The MathWorks, Inc.

hSrc = this.Application.DataSource;

if isempty(hSrc) || ~isDataLoaded(hSrc)
    enab = 'off';
else
    enab = 'on';
end

enableGUI(this, enab);

this.hVisualChangedListener = event.listener(this.Application, 'VisualChanged', @(h,ed) onVisualChanged(this));

function onVisualChanged(h)

if images.internal.isFigureAvailable()
    hUI = getGUI(h.Application);
    if isempty(hUI)
        h.ScrollPanelAPI = [];
    else
        hBtn = hUI.findchild('Base/Toolbars/Main/Tools/Zoom/Mag/MagCombo');
        hBtn.ScrollPanelAPI = [];
    end
end

% [EOF]