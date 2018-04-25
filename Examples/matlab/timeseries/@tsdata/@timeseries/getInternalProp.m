function propVal = getInternalProp(h,eventData,propName)

% Copyright 2006 The MathWorks, Inc.

% Use get rather than . reference for speed
if numel(h.TsValue)>0
    propVal = get(h.TsValue,propName);
else
    propVal = h.findprop(propName).FactoryValue;
end