function b = hasproposedfl(h,varargin)
%HASPROPOSEDFL(RUN)   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

b =false;
results = h.getBlkDgmResults(varargin{:});
if(isempty(results)); return; end
for r = 1:numel(results)
    if(results(r).hasProposedDT)
        b = true;
        break;
    end
end

% [EOF]
