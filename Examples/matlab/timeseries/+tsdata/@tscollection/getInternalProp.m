function propVal = getInternalProp(h,eventData,propName)

% Copyright 2006-2017 The MathWorks, Inc.

% Use get rather than . reference for speed
if numel(h.TsValue)>0
    propVal = get(h.TsValue,propName);
elseif h.findprop(propName).IsDefault
    propVal = h.findprop(propName).DefaultValue;
else
    propVal = [];
end