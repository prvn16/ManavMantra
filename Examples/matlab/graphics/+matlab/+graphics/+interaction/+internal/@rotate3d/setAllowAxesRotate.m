function setAllowAxesRotate(hThis,hAx,flag)
% Given an axes, determine whether rotate3d is allowed

% Copyright 2013 The MathWorks, Inc.

if ~islogical(flag)
    if ~all(flag==0 | flag==1)
        error(message('MATLAB:graphics:interaction:InvalidInputAxes'));
    end
end
if ~all(ishghandle(hAx,'axes'))
    error(message('MATLAB:rotate3d:InvalidInputZeroOne'));
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(hThis.FigureHandle,hFig)
        error(message('MATLAB:graphics:interaction:InvalidAxes'));
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'Rotate3d');
    hBehavior.Enable = flag;
end