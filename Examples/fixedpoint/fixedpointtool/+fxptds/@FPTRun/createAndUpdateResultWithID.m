function result = createAndUpdateResultWithID(this, data)
    % CREATEANDUPDATERESULTWITHID Converts the raw data to a result and stores it in the run. This result is shown in the FPT as a row.
    % This API is used only for MATLABFunctionBlock results
    
    % Copyright 2014-2017 The MathWorks, Inc.
    
    %narginchk(2,2);
    
    result = this.getResultByID(data.uniqueID);
    if(isempty(result))
        result = data.uniqueID.ResultConstructor(data);
        this.addResult(result);
        functionIdentifier = result.getUniqueIdentifier.MATLABFunctionIdentifier;
        blockHandle = functionIdentifier.BlockIdentifier.getObject.Handle;
        this.addMLFBHierarchy(blockHandle, {functionIdentifier});
    else
        this.updateResult(result, data);
    end
    
end

%--------------------------------------------------------------------------
% [EOF]
