function out = sum(this,varargin) 
% SUM  Return the sum of the time series data.
%
% SUM(TS) returns the sum of TS.Data
%
% SUM(TS,'PropertyName1', PropertyValue1,...) includes optional input
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
%   See also TIMESERIES/MIN, TIMESERIES/MAX
 
% Copyright 2004-2006 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this,'sum');
else
    if isempty(varargin)
        out = utStatCalculation(this,'sum');
    else
        out = utStatCalculation(this,'sum',varargin{:});
    end
end