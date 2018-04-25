function tf = hasdata(ds)
%HASDATA Returns true if there is more data in the SpreadsheetDatastore.
%   TF = hasdata(SSDS) returns true if there is more data in the
%   SpreadsheetDatastore SSDS, and false otherwise. read(SSDS) issues an
%   error when hasdata(SSDS) returns false.
%
%   Example:
%   --------
%      % Create a SpreadsheetDatastore
%      ssds = spreadsheetDatastore('airlinesmall_subset.xlsx')
%      % We are only interested in the Arrival Delay data
%      ssds.SelectedVariableNames = 'ArrDelay'
%      % Preview the first 8 rows of the data as a table
%      tab8 = preview(ssds)
%      % Sum the Arrival Delays
%      sumAD = 0;
%      ssds.ReadSize = 'sheet';
%      while hasdata(ssds)
%         tab = read(ssds);
%         data = tab.ArrDelay(~isnan(tab.ArrDelay)); % filter data
%         sumAD = sumAD + sum(data);
%      end
%      sumAD
%
%   See also - matlab.io.datastore.SpreadsheetDatastore, hasdata, readall, preview, reset.

%   Copyright 2015 The MathWorks, Inc.

    % return true if there is already data available for conversion or if there
    % are more splits with data which can be converted.
    try
        tf = ds.IsDataAvailableToConvert || hasdata@matlab.io.datastore.FileBasedDatastore(ds);
    catch ME
        throw(ME);
    end
end
