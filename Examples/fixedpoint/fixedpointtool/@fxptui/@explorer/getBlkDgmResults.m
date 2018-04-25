function results = getBlkDgmResults(h,varargin)
%GETBLKDGMRESULTS

%   Copyright 2006-2012 The MathWorks, Inc.

blkDgms = h.getBlkDgmNodes;
results = [];

for idx = 1:length(blkDgms)
    curBlkDgm = blkDgms(idx); 
    curResults = curBlkDgm.getRootResults(varargin{:}); 
    results = [results curResults]; %#ok<AGROW>
end
% [EOF]
