function TF = hasDatetimeDurationCategoricalLines(obj, axesDataProp)
%This is an undocumented function and may be removed in future.

%   hasDatetimeDurationCategoricalLines returns true if obj (which is expected to
%   be an axes) contains datetime, duration or categorical rulers in the axesDataProp 
%   property (which should be either 'XAxis' or 'YAxis'. 
%   Otherwise it returns false.

%   Copyright 2016 The MathWorks, Inc.

TF = false;
if isempty(obj) || ~(strcmp(axesDataProp, 'XAxis') || strcmp(axesDataProp, 'YAxis'))
    return
end
   
TF = isa(obj.(axesDataProp) ,'matlab.graphics.axis.decorator.DatetimeRuler') || ...
    isa(obj.(axesDataProp) ,'matlab.graphics.axis.decorator.DurationRuler') || ...
    isa(obj.(axesDataProp) ,'matlab.graphics.axis.decorator.CategoricalRuler');
