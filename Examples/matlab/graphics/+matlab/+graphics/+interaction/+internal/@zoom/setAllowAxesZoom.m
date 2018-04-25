function setAllowAxesZoom(hThis,hAx,flag)
% Given an axes, determine whether zoom is allowed

%   Copyright 2013 The MathWorks, Inc.

if ~all(ishghandle(hAx,'axes'))
    error(message('MATLAB:graphics:interaction:InvalidInputAxes'));
end

% If the flag input is not scalar, error.  If the flag is not logical,
% error if the value is not 0 or 1
if ~isscalar(flag) || (~islogical(flag) && ~((flag == 0) || (flag == 1)))
    error(message('MATLAB:zoom:InvalidInputZeroOne'))
end

for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(hThis.FigureHandle,hFig)
        error(message('MATLAB:graphics:interaction:InvalidAxes'));
    end
end

for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'zoom');
    hBehavior.Enable = flag;
end