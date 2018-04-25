function setDatetimeDurationTickFormat(h,type,val)
% This is an undocumented function and may be removed in a future release.

% Called by chart Line's DetetimeTickFormat and DurationTickFormat
% pseudo-properties to set axes tick formats.

%   Copyright 2016 The MathWorks, Inc.

ax = ancestor(h,'axes');
if ~isempty(ax) && isprop(ax,'ActiveXRuler')
    foundX = checkDim(ax.ActiveXRuler,type,val);
    foundY = checkDim(ax.ActiveYRuler,type,val);
    foundZ = checkDim(ax.ActiveZRuler,type,val);
    if ~foundX && ~foundY && ~foundZ
        error(message('MATLAB:plot:NoRulerForFormat',type));
    end
end

function found = checkDim(ruler,type,val)
found = false;
if (isa(ruler,'matlab.graphics.axis.decorator.DatetimeRuler') && strcmp(type,'datetime')) || ...
        (isa(ruler,'matlab.graphics.axis.decorator.DurationRuler') && strcmp(type,'duration'))
    ruler.TickLabelFormat = val;
    found = true;
end
