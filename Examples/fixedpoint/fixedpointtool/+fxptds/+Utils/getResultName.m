function resultName = getResultName(result)
%% GETRUNNAME function returns name of a given result
%
% result is an instance of fxptds.AbstractResult
% resultName is cellArray representing name of result

%   Copyright 2016-2017 The MathWorks, Inc.

    resultName = {};
    if ~isempty(result.UniqueIdentifier)
       resultName = {result.UniqueIdentifier.getDisplayName}; 
    end
    
end