function propertyChanged(this, eventData)
%PROPERTYCHANGED React to changes in the contained property objects.

%   Copyright 2012-2015 The MathWorks, Inc.

if ~ischar(eventData)
    eventData = get(eventData.AffectedObject, 'Name');
end

switch eventData
    case {'DataRangeMin', 'DataRangeMax'}
        updateScaling(this.ColorMap);
    case 'ColorMapExpression'
        colorMapExpressionChanged(this.ColorMap);
end

% [EOF]