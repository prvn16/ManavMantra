function out = mean(this,varargin) 
%MEAN  Return the mean value of the time series data
%
% MEAN(TS) returns the mean value of TS.Data.
%
% MEAN(TS,'PropertyName1', PropertyValue1,...) includes optional input
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
%   See also TIMESERIES/IQR, TIMESERIES/MEDIAN, TIMESERIES/STD
%

 
%   Copyright 2004-2006 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this,'mean');
else
    out = utStatCalculation(this,'mean',varargin{:});
end