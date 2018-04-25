function filteredResults = filterResultsByRunName(runName, results)
%% FILTERRESULTSBYRUNNAME function filters input results by input runName 
% i.e. filter results whose run name matches that of input "runName"

%   Copyright 2016 The MathWorks, Inc.

     % convert heterogenous array to cell array
    results = num2cell(results);
   
    % Query all results that match the given run name
    matchingResultIdces = cellfun(@(x) strcmpi(x.getRunName, runName), results);
    filteredResults = results(matchingResultIdces);
end