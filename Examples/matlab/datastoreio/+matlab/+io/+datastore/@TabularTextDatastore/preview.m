function previewData = preview(ds)
%PREVIEW Read 8 rows of data from TabularTextDatastore.
%   T = PREVIEW(TDS) reads 8 rows of data from the beginning of TDS.
%   T is a table with variables governed by TDS.SelectedVariableNames.
%   T has at most 8 rows.
%   PREVIEW does not affect the state of TDS.
%
%   Example:
%   --------
%      % Create a TabularTextDatastore
%      tabds = tabularTextDatastore('airlinesmall.csv')
%      % Preview 8 rows of the data
%      preview(tabds)
%      % Narrow focus to only the Arrival Delay data
%      tabds.SelectedVariableNames = 'ArrDelay'
%      % preview again
%      preview(tabds)
%
%   See also - matlab.io.datastore.TabularTextDatastore, hasdata, readall, read, reset.

%   Copyright 2014-2016 The MathWorks, Inc.

% imports
import matlab.io.datastore.TabularTextDatastore;

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
    dscopy.ReadSize = TabularTextDatastore.DEFAULT_PREVIEW_LINES;
    previewData = read(dscopy);
catch ME
    throw(ME);
end
end
