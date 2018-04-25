function b = hasApplicableProposals(this)
% HASAPPLICABLEPROPOSALS return true if contained results have data type proposals that can be applied.

% Copyright 2016 The MathWorks, Inc.

b = false;
results = this.getResultsAsCellArray;
for i = 1:numel(results)
    if results{i}.hasApplicableProposals
        b = true;
        break;
    end
end
