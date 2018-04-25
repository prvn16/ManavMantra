function tf = hasdata(ds)
%HASDATA Returns true if there is more data in the TabularTextDatastore.
%   TF = hasdata(TDS) returns true if there is more data in the
%   TabularTextDatastore TDS, and false otherwise. read(TDS) issues an
%   error when hasdata(TDS) returns false.
%
%   Example:
%   --------
%      % Create a TabularTextDatastore
%      tabds = tabularTextDatastore('airlinesmall.csv')
%      % Handle erroneous data
%      tabds.TreatAsMissing = 'NA'
%      tabds.MissingValue = 0;
%      % We are only interested in the Arrival Delay data
%      tabds.SelectedVariableNames = 'ArrDelay'
%      % Preview the first 8 rows of the data as a table
%      tab8 = preview(tabds)
%      % Sum the Arrival Delays
%      sumAD = 0;
%      while hasdata(tabds)
%         tab = read(tabds);
%         sumAD = sumAD + sum(tab.ArrDelay);
%      end
%      sumAD
%
%     See also matlab.io.datastore.TabularTextDatastore, read, readall, preview, reset.

%   Copyright 2014-2015 The MathWorks, Inc.

try
    tf = ~isempty(ds.CurrBuffer) || hasdata@matlab.io.datastore.FileBasedDatastore(ds);
catch ME
    throw(ME);
end
end
