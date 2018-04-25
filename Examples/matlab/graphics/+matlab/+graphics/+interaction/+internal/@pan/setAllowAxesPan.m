function setAllowAxesPan(hThis,hAx,flag)
% Given an axes, determine whether pan is allowed

% Copyright 2013 The MathWorks, Inc.

if ~islogical(flag)
    if ~all(flag==0 | flag==1)
        error(message('MATLAB:pan:InvalidInputZeroOne'))
    end
end
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
    hBehavior.Enable = flag;
end