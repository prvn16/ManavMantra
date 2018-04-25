function tsout = pvset(ts,varargin)
%PVSET  Set properties of time series.
%
%   TS = PVSET(TS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties 'Property1', 'Property2', ...
%
%   See also TIMESERIES\SET.

%   Copyright 2004-2011 The MathWorks, Inc.

if numel(ts)~=1
    error(message('MATLAB:timeseries:pvset:noarray'));
end
tsout = set(ts,varargin{:});
