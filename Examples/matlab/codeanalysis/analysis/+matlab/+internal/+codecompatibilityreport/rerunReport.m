function formattedResults = rerunReport(rerunConfiguration)
%rerunReport Reanalyze the report based on input arguments
%   rerunReport calls analyzeCodeCOmpatibility with the arguments that were
%   used to generated the orginal report. The packaged results are returned
%   back to he caller JS object.

%   Copyright 2017 The MathWorks, Inc.
    resolvedNameList = rerunConfiguration.resolvedNameList;

    includeSubfolders = rerunConfiguration.includeSubfolders;

    analysisResults = analyzeCodeCompatibility(resolvedNameList, 'IncludeSubfolders', includeSubfolders);

    import matlab.internal.codecompatibilityreport.getPackagedResults;
    formattedResults = getPackagedResults(analysisResults);
end
