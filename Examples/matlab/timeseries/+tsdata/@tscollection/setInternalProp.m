function propVal = setInternalProp(h,eventData,propName)

% Copyright 2006-2017 The MathWorks, Inc.

% Byspass using susref for performance
if numel(h.TsValue)>0
    h.TsValue = set(h.TsValue,propName,eventData);
end

propVal = eventData;