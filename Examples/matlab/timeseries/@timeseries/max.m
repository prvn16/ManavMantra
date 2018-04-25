function out = max(this,varargin) 
%MAX  Return the maximum value in the time series data
%
% MAX(TS) returns the max of TS.Data
%
% MAX(TS,'PropertyName1', PropertyValue1,...) includes optional input
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
%   See also TIMESERIES/SUM, TIMESERIES/MIN
%
 
%   Copyright 2005-2007 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this,'max');
else
    out = utStatCalculation(this,'max',varargin{:});
end