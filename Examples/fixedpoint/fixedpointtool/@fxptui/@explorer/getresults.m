function results = getresults(h,varargin)
%GETRESULTS

%   Author(s): G. Taillefer
%   Copyright 2006-2016 The MathWorks, Inc.

ds = h.getdataset;
if nargin > 1
    results = ds.getResultsFromRun(varargin{1});
else
    results = ds.getResultsFromRuns();
end


% [EOF]
