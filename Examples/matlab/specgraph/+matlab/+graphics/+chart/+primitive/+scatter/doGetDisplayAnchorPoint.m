function pt = doGetDisplayAnchorPoint(hObj, index)
%doGetDisplayAnchorPoint Get the data point to display a datatip at
%
%  doGetDisplayAnchorPoint(obj, index, factor) returns a data coordinate
%  where the datatip should be displayed for the specified data index.

%  Copyright 2016 The MathWorks, Inc.

% The anchor point is simply the data point.

numPoints = numel(hObj.XDataCache);
if index>0 && index<=numPoints
    zVal = 0;
    zData = hObj.ZDataCache;
    if ~isempty(zData)
        zVal = hObj.ZDataCache(index);
    end
    pt = [double(hObj.XDataCache(index)) double(hObj.YDataCache(index)) double(zVal)];
else
    pt = [NaN NaN NaN];
end
pt = matlab.graphics.shape.internal.util.SimplePoint(pt);
