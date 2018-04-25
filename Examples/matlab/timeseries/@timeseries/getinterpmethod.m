function out = getinterpmethod(ts)
%GETINTERPMETHOD  Get the interpolation method name for a time series object
%
%   GETINTERPMETHOD(TS) returns the interpolation method that is used by
%   the time series object TS as a string. Predefined interpolation methods are  
%   'zoh' (zero-order hold) and 'linear'(linear interpolation).
%
%   Example:
% 
%   Create a time series object:
%   ts=timeseries(rand(5))
%
%   Get the interpolation method for this object:
%   getinterpmethod(ts)
%
%   See also TIMESERIES/SETINTERPMETHOD, TIMESERIES/TIMESERIES

%   Copyright 2005-2011 The MathWorks, Inc.

if numel(ts)~=1
    error(message('MATLAB:timeseries:getinterpmethod:noarray'));
end

if ts.Length==0
    out = '';
    return;
end
out = ts.DataInfo.interpolation.name;