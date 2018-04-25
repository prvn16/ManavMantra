function data = readall(tds)
%READALL Read all of the datas rows from an TallDatastore.
%   T = READALL(TDS) reads all of the data rows from TDS.
%
%   See also matlab.io.datastore.TallDatastore, hasdata, read, preview, reset

%   Copyright 2016 The MathWorks, Inc.

try
    if isEmptyFiles(tds)
        data = getZeroFirstDimData(tds);
        return;
    end
    % reset the datastore to the beginning
    % reset also errors when files are deleted between save-load of the datastore
    % to/from MAT-Files (and between releases).
    tdsCopy = copy(tds);
    reset(tdsCopy);
    % read all the data
    data = readAllSplits(tdsCopy.Splitter);
    % Get only the values
    data = vertcat(data.Value{:});
catch ME
    throw(ME);
end
end
