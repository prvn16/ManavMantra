function b = hasunacceptedfl(h,run)
%HASPROPOSEDFL(RUN)   

%   Author(s): V. Srinivasan
%   Copyright 2006-2008 The MathWorks, Inc.

b = false;
results = h.getresults(run);
if(isempty(results)); return; end
for r = 1:numel(results)
    if (results(r).hasProposedDT && results(r).hasApplicableProposals)
       	b = true;
        break;
    end
end
