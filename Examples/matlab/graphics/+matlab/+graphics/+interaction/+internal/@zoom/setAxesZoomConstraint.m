function setAxesZoomConstraint(hThis,hAx,cons)
% Given an axes, determine the style of pan allowed

%   Copyright 2013 The MathWorks, Inc.

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
    hBehavior = hggetbehavior(hAx(i),'zoom');
    if strcmp(cons,'ZoomUnconstrained3D')
        cons = 'unconstrained';
    end
    hBehavior.Constraint3D = cons;
end