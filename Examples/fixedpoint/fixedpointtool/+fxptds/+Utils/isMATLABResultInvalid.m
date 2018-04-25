function isInvalid = isMATLABResultInvalid(result)
    % ISMATLABRESULTINVALID this function checks the properies of a MATLAB
    % result to determine whether a MALTAB result should be deemed invalid.
    
    % Copyright 2016 The MathWorks, Inc.
    
    % a MATLAB result may be invalid if...
    isInvalid = ... 
        isempty(result.getUniqueIdentifier.MATLABFunctionIdentifier.BlockIdentifier.getChartObject) || ... % if the parent chart object is invalid
        ~fxptds.isResultValid(result) || ... % if the data set record for this result is invalid
        ~result.hasValidRootFunctionIDs; % if the compilation report of the result is invalid
end