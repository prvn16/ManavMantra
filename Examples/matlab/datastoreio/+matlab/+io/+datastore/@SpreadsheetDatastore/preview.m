function previewData = preview(ds)
%PREVIEW Read 8 rows of data from SpreadsheetDatastore.
%   T = PREVIEW(SSDS) reads 8 rows of data from the beginning of SSDS.
%   T is a table with variables governed by SSDS.SelectedVariableNames.
%   T has at most 8 rows.
%   PREVIEW does not affect the state of SSDS.
%
%   Example:
%   --------
%      % Create a SpreadsheetDatastore
%      ssds = spreadsheetDatastore('airlinesmall_subset.xlsx')
%      % We are only interested in the Arrival Delay data
%      ssds.SelectedVariableNames = 'ArrDelay'
%      % Preview the first 8 rows of the data as a table
%      tab8 = preview(ssds)
%
%   See also - matlab.io.datastore.SpreadsheetDatastore, hasdata, readall, preview, reset.

%   Copyright 2015-2016 The MathWorks, Inc.

% imports
import matlab.io.datastore.SpreadsheetDatastore;

try
    % If files are empty, use READALL to get the correct empty table
    if isEmptyFiles(ds)
        previewData = readall(ds);
        return;
    end
    % make a copy of the datastore, reset the datastore to the beginning,
    % set the rows per read and preview on the copy.
    dscopy  = copy(ds);
    reset(dscopy);
    dscopy.ReadSize = SpreadsheetDatastore.DEFAULT_PREVIEW_LINES;
    previewData = read(dscopy);
catch ME
    throw(ME);
end
end
