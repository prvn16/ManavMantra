function result = createAndUpdateResult(this, dataObj)
    % CREATEANDUPDATERESULT Converts the raw data to a result and stores it in the run. This result is shown in the FPT as a row.
    
    %      Copyright 2012-2017 The MathWorks, Inc.
    
    narginchk(2,2);
    data = dataObj.getDataArray;
    
    for i = 1:numel(data)
        uniqueID = dataObj.getUniqueIdentifier(data(i));
        data(i).uniqueID = uniqueID;
        result = this.getResultByID(uniqueID);
        if(isempty(result))
            data(i).RunObject = this;
            result = dataObj.createResult(data(i));
            this.addResult(result);
        else
            this.updateResult(result, data(i));
        end
    end
    
end
%--------------------------------------------------------------------------
% [EOF]

