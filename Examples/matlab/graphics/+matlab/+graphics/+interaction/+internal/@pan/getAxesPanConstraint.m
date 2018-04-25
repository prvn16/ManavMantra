function cons = getAxesPanConstraint(hThis,hAx)

cons = cell(length(hAx),1);
if ~all(ishghandle(hAx,'axes'))
    error(message('MATLAB:graphics:interaction:InvalidInputAxes'));
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(hThis.FigureHandle,hFig)
        error(message('MATLAB:graphics:interaction:InvalidAxes'));
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'pan','-peek');
    if isempty(hBehavior)
        cons{i} = 'unconstrained';
    else
        cons{i} = hBehavior.Constraint3D;
        if strcmp(hBehavior.Constraint3D,'PanUnconstrained3D')
            cons{i} = 'unconstrained';
        end
    end
end
