function reset(tds)
%RESET Reset the TallDatastore to the start of the data.
%   RESET(TDS) resets TDS to the beginning of the datastore.
%
%   Example:
%   --------
%      % Create a simple tall double.
%      t = tall(rand(500,1))
%      % Write to a new folder.
%      newFolder = fullfile(pwd, 'myTest');
%      write(newFolder, t)
%      % Create an TallDatastore from newFolder
%      tds = datastore(newFolder)
%      % read 3 data rows at a time
%      tds.ReadSize = 3
%      while hasdata(tds)
%         a3 = read(tds)
%      end
%      % Reset to the beginning of the datastore
%      RESET(tds)
%      a3 = read(tds)
%
%   See also matlab.io.datastore.TallDatastore, read, readall, hasdata, preview

%   Copyright 2016 The MathWorks, Inc.
try
    if ~isempty(tds.Splitter) && isvalid(tds.Splitter) && ...
            tds.Splitter.NumSplits ~= 0
        tds.SplitIdx = 1;
        setSplitsWithValuesOnly(tds.Splitter, true);
        if ~isempty(tds.SplitReader) && isvalid(tds.SplitReader)
            tds.SplitReader.Split = tds.Splitter.Splits(tds.SplitIdx);
        else
            tds.SplitReader = createReader(tds.Splitter, tds.SplitIdx);
        end
        reset(tds.SplitReader);
    end
catch ME
    throw(ME);
end
end
