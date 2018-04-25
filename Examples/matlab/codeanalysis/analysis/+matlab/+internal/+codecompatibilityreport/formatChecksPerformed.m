function checksPerformed = formatChecksPerformed(cca)
%formatChecksPerformed Format ChecksPerformed from the input object
%   This function adds hyperlinks to the ChecksPerformed table from input

%   Copyright 2017 The MathWorks, Inc.
    checksPerformed = cca.ChecksPerformed;

    documentation = formatDocLink(checksPerformed.Documentation);

    checksPerformed = checksPerformed(:, {'Identifier', 'Description', 'Severity', ...
        'NumOccurrences', 'NumFiles'});

    checksPerformed.Documentation = documentation;
    checksPerformed = sortrows(checksPerformed, 'Severity', 'ascend');
    checksPerformed = sortrows(checksPerformed, 'NumFiles', 'descend');
    checksPerformed = sortrows(checksPerformed, 'NumOccurrences', 'descend');
end

function doc = formatDocLink(doc)
% Get the MATLAB href to execute the specified doc command.
    wantDocLink = strlength(doc) ~= 0 & ~ismissing(doc);
    doc(wantDocLink) = "matlab:" + doc(wantDocLink);
    doc(~wantDocLink) = "";
end
