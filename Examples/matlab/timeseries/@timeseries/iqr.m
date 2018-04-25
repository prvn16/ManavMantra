function out = iqr(this,varargin) 
%IQR  Return the interquartile range of the time series data values 
%
% IQR(TS) returns the interquartile range of TS.Data
%
% IQR(TS,'PropertyName1', PropertyValue1,...) includes optional input
% arguments: 
%       'MissingData': 'remove' (default) or 'interpolate'
%           indicates how to treat missing data during the calculation
%       'Quality': a vector of integers
%           indicates which quality codes represent missing samples
%           (vector case) or missing observations (>2 dimensional array
%           case) 
%       'Weighting': 'none' (default) or 'time'
%           When 'time' is used, large time values correspond to large weights. 


%   Copyright 2005-2006 The MathWorks, Inc.

if nargin==1
    out = utStatCalculation(this,'iqr');
else
    out = utStatCalculation(this,'iqr',varargin{:});
end