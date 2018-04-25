function b = hasDataTypeProposals(this)
% HASDATATYPEPROPOSALS return true if contained results have data type proposals.

% Copyright 2014-2016 The MathWorks, Inc.

	b = false;
	results = this.getResults;
	for i = 1:numel(results)
		if results(i).hasProposedDT
			b = true;
			break;
		end
	end
end