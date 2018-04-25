function wasUpdated = clearSignalForID(this, signalID)
% CLEARSIGNALFORID Clears the timeseries information from the result that is mapped to the signalID

% Copyright 2012 MathWorks, Inc.

    wasUpdated = false;
    if isempty(signalID); return; end
    results = this.getResults;
    for i = 1:length(results)
        wasUpdated = results(i).clearSignalForID(signalID);
        if wasUpdated
            break;
        end
    end
end

