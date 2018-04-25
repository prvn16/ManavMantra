function inCellStr = skipFormats(inCellStr)
%skipFormats insert skips in a cell array of strings.
%   This function is used to insert skips into a format string based on
%   whether it skipped. Skips are preserved if given.

%   Copyright 2014 The MathWorks, Inc.

% imports
import matlab.io.datastore.TabularTextDatastore;

% already validated cellstr is given
nFormats = numel(inCellStr);

for i = 1: nFormats
    formatStr = inCellStr{i};
    
    % create a formatParser struct
    tempStruct = matlab.iofun.internal.formatParser(formatStr);
    
    % the formats that come here are either skipped or unskipped. The
    % unskipped ones need to replace by %*q. We preserve the skipped
    % formats.
    if any(~tempStruct.IsSkipped)
        formatStr = TabularTextDatastore.DEFAULT_SKIP_FORMAT;
    end
    
    inCellStr{i} = formatStr;
end
end