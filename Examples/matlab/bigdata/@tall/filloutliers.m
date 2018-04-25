function [B, TF, LB, UB, C] = filloutliers(A, fillmethod, varargin)
% FILLOUTLIERS Fill outliers in data.
%
%   B = FILLOUTLIERS(A, FILL)
%   B = FILLOUTLIERS(A, FILL, METHOD)
%   B = FILLOUTLIERS(A, FILL, MOVMETHOD, WINDOW)
%   B = FILLOUTLIERS(..., DIM)
%   B = FILLOUTLIERS(..., Name, Value)
%   [B, TF, LTHRESH, UTHRESH, CENTER] = ISOUTLIER(...)
%
%   Limitations: 
%   1) The 'grubbs' and 'gesd' methods are not supported. 
%   2) The 'movmedian' and 'movmean' methods do not support tall
%      timetables.
%   3) The 'SamplePoints' and 'MaxNumOutliers' name-value pairs are not
%      supported. 
%   4) The value of 'DataVariables' cannot be a function_handle.
%   5) Computation of FILLOUTLIERS(A,FILL),
%      FILLOUTLIERS(A,FILL,'median',...), or
%      FILLOUTLIERS(A,FILL,'quartiles',...) along the first dimension is
%      only supported for tall column vectors A.
%   6) FILLOUTLIERS(A,'spline',...) is not supported.
%
%   See also FILLOUTLIERS, TALL/ISOUTLIER, TALL/FILLMISSING, TALL/RMMISSING

% Copyright 2017 The MathWorks, Inc.

try
    [TF, LB, UB, C, B] = locateOutliers(A, fillmethod, varargin{:});
catch err
    throwAsCaller(err);
end
