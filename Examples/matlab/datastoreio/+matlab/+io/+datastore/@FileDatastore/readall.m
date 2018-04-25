function data = readall(fds)
%READALL Read all of the files from the datastore.
%   DATAARR = READALL(FDS) reads all of the files from FDS.
%   DATAARR is a cell array containing the data returned by the read method
%   on reading all the files in the FileDatastore.
%
%   See also fileDatastore, hasdata, read, preview, reset.

%   Copyright 2015-2017 The MathWorks, Inc.

try
    if isEmptyFiles(fds)
        data = fds.BufferedZero1DimData;
        return;
    end
    fdsCopy = copy(fds);
    reset(fdsCopy);
    data = cell(numel(fdsCopy.Files), 1);
    ii = 1;
    while hasdata(fdsCopy)
        data{ii} = read(fdsCopy);
        ii = ii + 1;
    end
    if fds.UniformRead
        data = vertcat(data{:});
    end
catch ME
    throw(ME);
end
