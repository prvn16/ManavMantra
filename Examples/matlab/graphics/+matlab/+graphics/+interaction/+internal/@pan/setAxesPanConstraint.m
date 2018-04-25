function setAxesPanConstraint(hThis,hAx,cons)

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
    hBehavior = hggetbehavior(hAx(i),'pan');
    if strcmp(cons,'PanUnconstrained3D')
        cons = 'unconstrained';
    end
    hBehavior.Constraint3D = cons;
end
