function l = length(this) 

%LENGTH  Return the length of the time vector
%
%   LENGTH(TS) returns n, where n is an integer that represents the length
%   of the time vector. 
%
%   See also TIMESERIES/ISEMPTY, TIMESERIES/SIZE

%   Copyright 2005-2010 The MathWorks, Inc.

if isempty(this.TsValue)
    l = 0;
else
    l = this.TsValue.Length;
end


