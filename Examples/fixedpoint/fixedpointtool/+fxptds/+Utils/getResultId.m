function resultId = getResultId(result)
%% GETRESULTID static function returns the uniqueId of a fxptds.AbstractResult
%
% result is an instance of fxptds.AbstractResult
% resultId is cell array representing unique key of the result.

%   Copyright 2016-2017 The MathWorks, Inc.
    
    resultId = {result.UniqueIdentifier.UniqueKey};
end