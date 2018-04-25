function objtypes = getChartingObjectTypes(className)

% Copyright 2015 The MathWorks, Inc.

objtypes = {'matlab.graphics.chart.primitive.Line','matlab.graphics.chart.primitive.Surface',...
    'matlab.graphics.chart.primitive.Stem','matlab.graphics.chart.primitive.Stair','matlab.graphics.chart.primitive.Bar',...
    'matlab.graphics.chart.primitive.Area','matlab.graphics.chart.primitive.ErrorBar','matlab.graphics.chart.primitive.Contour',...
    'matlab.graphics.chart.primitive.Quiver','matlab.graphics.chart.primitive.Scatter','matlab.graphics.primitive.Patch'};
if nargin==0 || isempty(className)
    return;
else
    regStr = ['\.' className '$'];
    I = cellfun(@(x) ~isempty(regexp(x,regStr,'once')),objtypes);
    if any(I)
        objtypes = objtypes{find(I,1)};
    else
        objtypes = [];
    end
end
    