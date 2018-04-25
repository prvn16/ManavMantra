function allRunNames = getAllRunNamesUsingModelSource(this, modelSource)
%% GETALLRUNNAMESUSINGMODELSOURCE function uses model source name to get all runnames with results

%   Copyright 2017 The MathWorks, Inc.

    % Access dataset from FPTRepository
    fptRepository = fxptds.FPTRepository.getInstance;
    dataset = fptRepository.getDatasetForSource(modelSource);
    allRunNames = this.getAllRunNamesWithResults(dataset);
end