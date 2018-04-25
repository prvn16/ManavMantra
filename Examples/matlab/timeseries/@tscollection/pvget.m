function [Value,ValStr] = pvget(tsc,Property)
%PVGET  Get values of tscollection properties.
%
%   VALUES = PVGET(TSC) returns the property values in a cell array VALUES.
%
%   VALUE = PVGET(TSC,PROPERTY) returns the value of PROPERTY.
%
%   See also TSCOLLECTION\GET.

%   Copyright 2004-2016 The MathWorks, Inc.


if nargin==2
   % Value of single property: VALUE = PVGET(TS,PROPERTY)
   Value = tsc.(char(Property));
else
   % Return all public property values
   PropNames = fieldnames(tsc);
   Value = cell(length(PropNames),1);
   for k=1:length(PropNames)
       Value{k} = get(tsc,PropNames{k});
   end
   if nargout==2
      ValStr = pvformat(tsc,Value);
   end
end
