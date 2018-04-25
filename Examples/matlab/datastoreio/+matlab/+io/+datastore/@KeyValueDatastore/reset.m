function reset(kvds)
%RESET Reset the KeyValueDatastore to the start of the data.
%   RESET(KVDS) resets KVDS to the beginning of the datastore.
%
%   Example:
%   --------
%      % 'mapredout.mat' is the output file of a mapreduce function.
%      kvds = datastore('mapredout.mat')
%      kvds.ReadSize = 3
%      % Read 3 key-value pairs
%      kv3 = read(kvds)
%      % Reset to the beginning of the datastore
%      RESET(kvds)
%      % Read the same 3 key-value pairs
%      kv3 = read(kvds)
%
%   See also matlab.io.datastore.KeyValueDatastore, read, readall, hasdata, preview

%   Copyright 2014-2016 The MathWorks, Inc.
try
    if ~isempty(kvds.Splitter) && isvalid(kvds.Splitter) && ...
            kvds.Splitter.NumSplits ~= 0
        kvds.SplitIdx = 1;
        setSplitsWithValuesOnly(kvds.Splitter, false);
        if ~isempty(kvds.SplitReader) && isvalid(kvds.SplitReader)
            kvds.SplitReader.Split = kvds.Splitter.Splits(kvds.SplitIdx);
        else
            kvds.SplitReader = createReader(kvds.Splitter, kvds.SplitIdx);
        end
        reset(kvds.SplitReader);
    end
catch ME
    throw(ME);
end
end
