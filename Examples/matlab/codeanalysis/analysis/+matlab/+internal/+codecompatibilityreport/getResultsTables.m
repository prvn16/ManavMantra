function [errorDepRecommendations, syntaxRecommendations, warningDepRecommendations, otherDepRecommendations, checksPerformed, files ] = getResultsTables(cca)
%getResultsTables Return formatted tables that will be displayed on the report
%   Returns formatted tables to be displayed on the report
%   from the input CodeCompatibilityAnalysis object

%   Copyright 2017 The MathWorks, Inc.

    import matlab.internal.codecompatibilityreport.formatFiles;
    import matlab.internal.codecompatibilityreport.formatChecksPerformed;
    import matlab.internal.codecompatibilityreport.formatRecommendations;

    files = formatFiles(cca);
    checksPerformed = formatChecksPerformed(cca);
    [warningDepRecommendations, errorDepRecommendations, otherDepRecommendations, syntaxRecommendations] = formatRecommendations(cca);

    errorDepRecommendations = convertStringsToChar(errorDepRecommendations);
    syntaxRecommendations = convertStringsToChar(syntaxRecommendations);
    warningDepRecommendations = convertStringsToChar(warningDepRecommendations);
    otherDepRecommendations = convertStringsToChar(otherDepRecommendations);
    checksPerformed = convertStringsToChar(checksPerformed);
    files = convertStringsToChar(files);
end

function charTable = convertStringsToChar(strTable)
%This function returns the input table with strings
%and categorical fields converted to character vectors
    charTable = varfun(@convert, strTable);
end

function x = convert(x)
    if isstring(x) || iscategorical(x)
        x = cellstr(x);
    end
end
