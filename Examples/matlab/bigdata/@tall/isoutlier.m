function [TF, LB, UB, C] = isoutlier(A, varargin)
% ISOUTLIER Detect outliers in data.
%
%   TF = ISOUTLIER(A)
%   TF = ISOUTLIER(A, METHOD)
%   TF = ISOUTLIER(A, MOVMETHOD, WINDOW)
%   TF = ISOUTLIER(..., DIM)
%   TF = ISOUTLIER(..., Name, Value)
%   [TF, LTHRESH, UTHRESH, CENTER] = ISOUTLIER(...)
%
%   Limitations: 
%   1) The 'grubbs' and 'gesd' methods are not supported. 
%   2) The 'movmedian' and 'movmean' methods do not support tall
%      timetables.
%   3) The 'SamplePoints' and 'MaxNumOutliers' name-value pairs are not
%      supported. 
%   4) The value of 'DataVariables' cannot be a function_handle.
%   5) Computation of ISOUTLIER(A), ISOUTLIER(A,'median',...), or
%      ISOUTLIER(A,'quartiles',...) along the first dimension is only
%      supported for tall column vectors A.
%
%   See also ISOUTLIER, TALL/FILLOUTLIERS, TALL/FILLMISSING, TALL/RMMISSING

% Copyright 2017 The MathWorks, Inc.

try
    [TF, LB, UB, C] = locateOutliers(A, varargin{:});
catch err
    throwAsCaller(err);
end
