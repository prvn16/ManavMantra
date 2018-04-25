function wasUpdated = clearSignalForID(this, signalID)
% CLEARSIGNALFORID Clears the time-series ID indicated by the signalID if present in the result.

% Copyright 2013-2014 The MathWorks, Inc.
    
    wasUpdated = false;
    idx = find(this.TimeSeriesID==signalID, 1);
    if ~isempty(idx)
        if sum(this.TimeSeriesID ~= 0) > 1
            this.TimeSeriesID(idx) = 0;
        else
            this.TimeSeriesID = 0;
            this.IsPlottable = false;
        end
        wasUpdated = true;
        this.updateVisibility;
    end
end
