function [data, info] = read(tds)
%READ Read data rows from a TallDatastore.
%   T = READ(TDS) reads some data rows from TDS.
%   TDS.ReadSize controls the number of data rows that are
%   read.
%   read(TDS) errors if there are no more data rows in TDS,
%   and should be used with hasdata(TDS).
%
%   [T,info] = READ(TDS) also returns a structure with additional
%   information about TDS. The fields of info are:
%      Filename - Name of the file from which data was read.
%      FileSize - Size of the file (Size of Value variable for 'mat', bytes for
%                 'seq').
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
%
%   See also matlab.io.datastore.TallDatastore, hasdata, readall, preview, reset.

%   Copyright 2016 The MathWorks, Inc.
try
    warning('off', 'MATLAB:MatFile:OlderFormat');
    c = onCleanup(@() warning('on', 'MATLAB:MatFile:OlderFormat'));
    readSize = tds.ReadSize;

    if tds.BufferedSize == 0
        [d, tds.BufferedInfo] = readData(tds);
        d = vertcat(d{:});
        % first dimension is the ReadSize dimension
        tds.BufferedSize = size(d, 1);
        tds.BufferedData = d;
    end

    if tds.BufferedSize == readSize
        data = tds.BufferedData;
        info.Filename = tds.BufferedInfo.Filename;
        info.FileSize = tds.BufferedInfo.FileSize;
        tds.BufferedSize = 0;
        return;
    end

    while tds.BufferedSize < readSize && hasNext(tds.SplitReader)
        % We are getting data from the same file, if needed.
        % Can we do hasdata and readData, instead?
        % info.Filename will be a cell array in this case.
        [d, tds.BufferedInfo] = getNext(tds.SplitReader);
        d = vertcat(d{:});
        % first dimension is the ReadSize dimension
        tds.BufferedSize = tds.BufferedSize + size(d, 1);
        tds.BufferedData = vertcat(tds.BufferedData, d);
    end

    % Get data and info, from buffered data and its info
    data = getDataUsingSubstructInfo(tds, min(readSize, tds.BufferedSize));
    info.Filename = tds.BufferedInfo.Filename;
    info.FileSize = tds.BufferedInfo.FileSize;
catch e
    throw(e)
end
end
