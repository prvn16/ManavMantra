function hasDerived = hasDerivedMinMax(h)
%HASDERIVEDMINMAX % Return true if the results have either derived min or derived max.

%   Copyright 2010-2014 The MathWorks, Inc.

ds = h.getdataset;
res = ds.getResultsFromRuns;
hasDerived = false;
for i = 1:numel(res)
    hasDerived = res(i).hasDerivedMinMax;
    if hasDerived; return; end
end
% Check the referenced results for derived min/max
if ~hasDerived
    res = h.getBlkDgmResults;
    for i = 1:numel(res)
        hasDerived = res(i).hasDerivedMinMax;
        if hasDerived; return; end
    end
end
    
   
% [EOF]
