function propVal = setInternalProp(h,eventData,propName)

% Copyright 2006-2008 The MathWorks, Inc.

% Bypass using susref for performance
if numel(h.TsValue)>0 % Do not use isempty here - it is overridden
   h.TsValue.(propName) = eventData;
   %h.TsValue.BeingBuilt = false;
end

% Fire a datachange event even though the new property value has not yet
% been assigned. It's ok because property values will be read from
% tsValue, which is up to date
h.fireDataChangeEvent(tsdata.dataChangeEvent(h,propName,[]));
propVal = eventData; 
