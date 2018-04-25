function out = std(this,varargin) 
% STD  Return the standard deviation of time series data.
%
% STD(TS) returns the standard deviation of TS.Data.
%
% STD(TS,'PropertyName1', PropertyValue1,...) includes optional input
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
%   See also TIMESERIES/MEAN, TIMESERIES/IQR, TIMESERIES/MEDIAN,
%   TIMESERIES/VAR
%

% Copyright 2004-2006 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this,'std');
else
    if isempty(varargin)
        out = utStatCalculation(this,'std');
    else
        out = utStatCalculation(this,'std',varargin{:});
    end
end