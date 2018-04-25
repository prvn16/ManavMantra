function hasSim = hasSimMinMax(h)
%HASSIMMINMAX  Return true if the results have either Sim min or Sim max.

%   Copyright 2010-2014 The MathWorks, Inc.

ds = h.getdataset;
res = ds.getResultsFromRuns;
hasSim = false;
for i = 1:numel(res)
    hasSim = res(i).hasSimMinMax;
    if hasSim; return; end
end
% Check the referenced results for sim min/max
if ~hasSim
    res = h.getBlkDgmResults;
    for i = 1:numel(res)
        hasSim = res(i).hasSimMinMax;
        if hasSim; return; end
    end
end

% [EOF]
