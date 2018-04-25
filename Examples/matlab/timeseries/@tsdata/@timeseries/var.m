function out = var(this,varargin) 
%VAR  Return the variance of the values in time series data.
%
% VAR(TS) returns the variance of TS.Data
%
% VAR(TS,'PropertyName1', PropertyValue1,...) includes optional input
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
%   See also TIMESERIES/MEAN, TIMESERIES/IQR, TIMESERIES/MEDIAN
%

% Copyright 2004-2014 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this.Tsvalue,'var');
else
    if isempty(varargin)
        out = utStatCalculation(this.Tsvalue,'var');
    else
        out = utStatCalculation(this.Tsvalue,'var',varargin{:});
    end
end