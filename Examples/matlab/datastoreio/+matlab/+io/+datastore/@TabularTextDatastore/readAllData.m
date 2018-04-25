function data = readAllData(ds)
%READALLDATA Read all of the data from a TabularTextDatastore.
%   T = READALLDATA(TDS) reads all of the data from TDS.
%   T is a table with variables governed by TDS.SelectedVariableNames.
%
%   Example:
%   --------
%      % Create a TabularTextDatastore
%      tabds = tabularTextDatastore('airlinesmall.csv')
%      % Handle erroneous data
%      tabds.TreatAsMissing = 'NA';
%      tabds.MissingValue = 0;
%      % We are only interested in the Arrival Delay data
%      tabds.SelectedVariableNames = 'ArrDelay'
%      tab = readall(tabds);
%      sumAD = sum(tab.ArrDelay)
%
%   See also - matlab.io.datastore.TabularTextDatastore, hasdata, read, preview, reset.

%   Copyright 2016 The MathWorks, Inc.

try
    dsCopy = copy(ds);
    reset(dsCopy);

    % If empty files return an empty table with correct SelectedVariableNames
    if isEmptyFiles(dsCopy) || ~hasdata(dsCopy)
        data = emptyTabular(dsCopy,dsCopy.SelectedVariableNames);
        return;
    end

    % estimate max rows per read by num variables
    dsCopy.ReadSize = max( 1, floor(4e6/numel(dsCopy.VariableNames)) );

    tblCells = cell(1, dsCopy.Splitter.NumSplits);
    readIdx = 1;
    while hasdata(dsCopy)
        tblCells{readIdx} = read(dsCopy);
        readIdx = readIdx + 1;
    end

    data = vertcat(tblCells{:});
catch ME
    throw(ME);
end
end
