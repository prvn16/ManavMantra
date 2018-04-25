function data = readAllData(ds)
%READALLDATA Read all of the data from a SpreadsheetDatastore.
%   T = READALLDATA(SSDS) reads all of the data from SSDS.
%   T is a table with variables governed by SSDS.SelectedVariableNames.
%
%   Example:
%   --------
%      % Create a SpreadsheetDatastore
%      ssds = spreadsheetDatastore('airlinesmall_subset.xlsx')
%      % We are only interested in the Arrival Delay data
%      ssds.SelectedVariableNames = 'ArrDelay'
%      % read all the data
%      tab = readall(ssds);
%
%   See also - matlab.io.datastore.SpreadsheetDatastore, hasdata, readall, preview, reset.

%   Copyright 2016 The MathWorks, Inc.

    try
        dsCopy = copy(ds);
        reset(dsCopy);

        % If empty files return an empty table with correct SelectedVariableNames
        if isEmptyFiles(dsCopy) || ~hasdata(dsCopy)
            data = emptyTabular(dsCopy,dsCopy.SelectedVariableNames);
            return;
        end

        % set ReadSize to 'file'
        dsCopy.ReadSize = 'file';
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
