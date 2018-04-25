function rmFigure(h,f)

% Removes a reference to a linked figure from the linkplotmanager.

%   Copyright 2008 The MathWorks, Inc.

if isempty(h.Figures)
    return
end
I = find([h.Figures.('Figure')]==f);

% Close LinkedPlotPanel
if strcmp(get(f,'BeingDeleted'),'off') && ~isempty(h.Figures(I)) && ...
        ~isempty(h.Figures(I).Panel)
    h.Figures(I).Panel.close;
    % Deactivate listeners
    h.Figures(I).EventManager.Enable = 'off';
end
h.Figures(I) = [];

% Garbage collect any orphaned variables from the brushmanager.
b = datamanager.BrushManager.getInstance();
b.reconcile;