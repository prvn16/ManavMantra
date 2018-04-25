function tf = hasdata(tds)
%HASDATA Returns true if there is more data in the TallDatastore.
%   TF = HASDATA(TDS) returns true if there are more key-value pairs
%   in the TallDatastore TDS, and false otherwise.
%   read(TDS) returns an error when HASDATA(TDS) returns false.
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
%
%      while HASDATA(tds)
%         % read one row of data at a time
%         a1 = read(tds)
%      end
%
%   See also matlab.io.datastore.TallDatastore, read, readall, preview, reset.

%   Copyright 2016-2017 The MathWorks, Inc.
try
    % If data is already buffered, BufferedSize will be > 0 and no need to check
    % hasNext from the SplitReader
    tf =  (~isempty(tds.BufferedSize) && tds.BufferedSize > 0 ) || ...
        hasdata@matlab.io.datastore.FileBasedDatastore(tds);
catch e
    throw(e);
end
end
