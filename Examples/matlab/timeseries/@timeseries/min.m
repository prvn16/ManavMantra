function out = min(this,varargin) 
%MIN  Return the minimum value in the time series data
%
% MIN(TS) return the min of TS.Data
%
% MIN(TS,'PropertyName1', PropertyValue1,...) includes optional input
% arguments: 
%       'MissingData': 'remove' (default) or 'interpolate'
%           indicates how to treat missing data during the calculation
%       'Quality': a vector of integers
%           indicates which quality codes represent missing samples
%           (vector case) or missing observations (>2 dimensional array
%           case) 
%       'Weighting': 'none' (default) or 'time'
%           When 'time' is used, large time values correspond to large weights. 
%
%   See also TIMESERIES/SUM, TIMESERIES/MAX
%
 
%   Copyright 2004-2006 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this,'min');
else
    out = utStatCalculation(this,'min',varargin{:});
end