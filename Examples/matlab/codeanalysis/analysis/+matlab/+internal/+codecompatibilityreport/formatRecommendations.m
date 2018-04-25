function [compatWarnings, compatErrors, otherWarnings, syntaxErrors] = formatRecommendations(cca)
%formatRecommendations Format recommendations from the input object.
%   This function splits the recommendations from the input codeCompatibilityAnalysis
%   object into two tables - errors and warnings, and adds hyperlinks.

%   Copyright 2017 The MathWorks, Inc.

    reccomendationsWithCategories = innerjoin(cca.ChecksPerformed(:, {'CategoryIdentifier','Identifier'}), cca.Recommendations);
    isDeps = (reccomendationsWithCategories.CategoryIdentifier == 'COMPAT');
    isDepsWarning = (isDeps & reccomendationsWithCategories.Severity=='Warning');
    isDepsError = (isDeps & reccomendationsWithCategories.Severity=='Error');
    isDepsOther = (reccomendationsWithCategories.CategoryIdentifier == 'OLDAPI');
    isSyntaxError = (~isDepsWarning & ~isDepsError & ~isDepsOther); % syntax and fatal messages

    compatWarnings = formatTable(cca.Recommendations(isDepsWarning, :));
    compatErrors = formatTable(cca.Recommendations(isDepsError, :));
    otherWarnings = formatTable(cca.Recommendations(isDepsOther, :));
    syntaxErrors = formatTable(cca.Recommendations(isSyntaxError, :));
end

function formatted = formatTable(recommendations)
    formatted = recommendations(:, {'Description', 'Severity'});
    formatted.Documentation = formatDocLink(recommendations.Documentation);
    formatted.Identifier = recommendations.Identifier;
    formatted.Location = formatLocation(recommendations.File, ...
                                        recommendations.LineNumber,  ...
                                        recommendations.ColumnRange(:,1));
    formatted.File = recommendations.File;
    formatted.Line = recommendations.LineNumber;
    formatted.Filename = formatFilename(recommendations.File);
    formatted = formatted(:, {'Identifier', 'Documentation', ...
                        'Description', 'Location', 'File', 'Line', 'Filename'});

    % Sort the table. This will be the default sort order in the report.
    formatted = sortrows(formatted, {'File', 'Filename', 'Line'});
    formatted.RowNumber = (1:height(formatted))';
    formatted.PaddedLine = padLine(formatted.Line);
end

function padded = padLine(lineNumber)
% Pad line numbers to begin with 0s and return as strings.
% This enables sorting to consider line numbers as strings and still sort
% correctly in the report.
    padded = string(lineNumber);
    len = max(strlength(padded));
    if len > 0
        padded = pad(padded, len, 'left', '0');
    end
end

function filename = formatFilename(filename)
% Trim the file name down to just file name and the extension.
    for i = numel(filename):-1:1
        [~, f, ext] = fileparts(filename(i));
        filename(i) = f + ext;
    end
end

function location = formatLocation(file, lineNumber, column)
% Get the MATLAB href to open the files to the specified lines and columns.

% Use compose rather than sprintf because compose provides the vectorized
% behaviour we need: Each row in the input arguments yields a row in the
% output.
    location = compose("matlab:opentoline('%s',%2d,%2d)", file, lineNumber, column);
end

function doc = formatDocLink(doc)
% Get the MATLAB href to execute the specified doc command.
    wantDocLink = strlength(doc) ~= 0 & ~ismissing(doc);
    doc(wantDocLink) = "matlab:" + doc(wantDocLink);
    doc(~wantDocLink) = "";
end
