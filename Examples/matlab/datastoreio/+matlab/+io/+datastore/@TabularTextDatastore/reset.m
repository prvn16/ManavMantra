function reset(ds)
%RESET Reset the TabularTextDatastore to the start of the data.
%   RESET(TDS) resets TDS to the beginning of the datastore.
%
%   Example:
%   --------
%      % Create a TabularTextDatastore
%      tabds = tabularTextDatastore('airlinesmall.csv')
%      % Handle erroneous data
%      tabds.TreatAsMissing = 'NA';
%      tabds.MissingValue = 0;
%      % Narrow focus to only the Arrival Delay data
%      tabds.SelectedVariableNames = 'ArrDelay'
%      % Read some data to explore and work on your algorithm
%      tab = read(tabds);
%      sumAD = sum(tab.ArrDelay)
%      tab = read(tabds);
%      sumAD = sumAD + sum(tab.ArrDelay)
%      % Since reading from the datastore above affected the state
%      % of tabds, reset to the beginning of the datastore:
%      reset(tabds)
%      % Now apply your algorithm to all of the data in tabds
%      sumAD = 0;
%      while hasdata(tabds)
%         tab = read(tabds);
%         sumAD = sumAD + sum(tab.ArrDelay);
%      end
%      sumAD
%
%   See also - matlab.io.datastore.TabularTextDatastore, read, readall, hasdata, preview.

%   Copyright 2014-2015 The MathWorks, Inc.

try
    reset@matlab.io.datastore.FileBasedDatastore(ds);
catch ME
    throw(ME);
end

% reset TabularTextDatastore internal state management properties
ds.NumCharactersReadInChunk = 0;
ds.CurrBuffer = '';
ds.CurrSplitInfo = [];
end
