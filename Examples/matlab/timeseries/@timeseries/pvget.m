function [Value,ValStr] = pvget(ts,Property)
%PVGET  Get values of time series properties.
%
%   VALUES = PVGET(TS) returns the property values in a cell array VALUES.
%
%   VALUE = PVGET(TS,PROPERTY) returns the value of PROPERTY.
%
%   See also TIMESERIES\GET.

%   Copyright 2005-2016 The MathWorks, Inc.

if numel(ts)~=1
    error(message('MATLAB:timeseries:pvget:noarray'));
end
if nargin==2
   % Value of single property: VALUE = PVGET(TS,PROPERTY)
   Value = ts.(char(Property));
else
   % Return all public property values
   % RE: Private properties always come last in LTIPropValues
   PropNames = fieldnames(ts);
   PropValues = struct2cell(struct(ts));
   Value = PropValues(1:length(PropNames));
   if nargout==2
      ValStr = tspvformat(Value);
   end
end