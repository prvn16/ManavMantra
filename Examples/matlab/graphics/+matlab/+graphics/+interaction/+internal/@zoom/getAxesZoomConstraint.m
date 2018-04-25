function cons = getAxesZoomConstraint(hThis,hAx)
% Given an axes, determine the style of pan allowed

% Copyright 2013 The MathWorks, Inc.

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
    hBehavior = hggetbehavior(hAx(i),'zoom','-peek');
    if isempty(hBehavior)
        cons{i} = 'unconstrained';
    else
        cons{i} = hBehavior.Constraint3D;
        if strcmp(hBehavior.Constraint3D,'ZoomUnconstrained3D')
            cons{i} = 'unconstrained';
        end
    end
end