function textDs = createTextDSWithKeyValueVarNames(filesOrDirs, varargin)
%CREATETEXTDSWITHKEYVALUEVARNAMES Creates a TabularTextDatastore with Key-Value variable names.

%   Copyright 2014-2015 The MathWorks, Inc.

% filtering based on allowed extensions alone.
allowedExts = { '.txt', '.csv', '.dat', '.dlm', '.asc', '.text', ''};
textDs = datastore(filesOrDirs, 'Type', 'TabularText', 'ReadVariableNames', false, ...
                                'Delimiter', '\t', 'WhiteSpace', ' \b', ...
                                'FileExtension', allowedExts);
numVars = numel(textDs.VariableNames);
if numVars >= 1
    textDs.VariableNames{1} = 'Key';
end
if numVars >= 2
    textDs.VariableNames{2} = 'Value';
end
if numVars > 2
    textDs.VariableNames(3:numVars) = matlab.internal.datatypes.numberedNames('Value', 2:numVars-1, false);
end
