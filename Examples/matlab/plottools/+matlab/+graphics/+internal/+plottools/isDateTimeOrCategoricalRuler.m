function ret = isDateTimeOrCategoricalRuler(hAxes)
% This is an undocumented function and may be removed in future.


% isDateTimeOrCategoricalRuler returns an 1x3 logical array indicating if X,Y,Z rulers
% of the given axes are of type datetime/duration . This is a utility function for Plot tools

%   Copyright 2016 The MathWorks, Inc.

ret    = false(1,3);
ret(1) = isa(hAxes.XAxis,'matlab.graphics.axis.decorator.DatetimeRuler') || ...
    isa(hAxes.XAxis,'matlab.graphics.axis.decorator.DurationRuler') || ...
    isa(hAxes.XAxis,'matlab.graphics.axis.decorator.CategoricalRuler');
ret(2) = isa(hAxes.YAxis,'matlab.graphics.axis.decorator.DatetimeRuler') || ...
    isa(hAxes.YAxis,'matlab.graphics.axis.decorator.DurationRuler') || ...
    isa(hAxes.YAxis,'matlab.graphics.axis.decorator.CategoricalRuler'); 
ret(3) = isa(hAxes.ZAxis,'matlab.graphics.axis.decorator.DatetimeRuler') || ...
    isa(hAxes.ZAxis,'matlab.graphics.axis.decorator.DurationRuler') || ...
    isa(hAxes.ZAxis,'matlab.graphics.axis.decorator.CategoricalRuler');
end