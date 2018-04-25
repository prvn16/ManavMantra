function out = mode(this,varargin) 
%MODE  Return the mode value in time series data
%
% MODE(TS) returns the median of TS.Data
%
% MODE(TS,'PropertyName1', PropertyValue1,...) includes optional input
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
%   See also TIMESERIES/MEAN, TIMESERIES/IQR, TIMESERIES/STD
%
 
%   Copyright 2010 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this,'mode');
else
    out = utStatCalculation(this,'mode',varargin{:});    
end