function clearRangeAnalysisResults(this, results)
% CLEARRANGEANALYSISRESULTS clears the derived min/max results from the run.

%   Copyright 2012-2016 The MathWorks, Inc.
	for i = 1:length(results)
		results(i).clearDerivedRangeData;
	end

	ascalerData = this.getMetaData;
	if ~isempty(ascalerData)
		ascalerData.clearInternalDerivedRangeData();
	end   
end