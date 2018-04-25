function data = readAllData(kvds)
%READALLDATA Read all of the key-value pairs from a KeyValueDatastore.
%   T = READALLDATA(KVDS) reads all of the key-value pairs from KVDS.
%   T is a table with variables 'Key' and 'Value'.
%
%   See also matlab.io.datastore.KeyValueDatastore, hasdata, read, preview, reset

%   Copyright 2016 The MathWorks, Inc.

try
    % reset the datastore to the beginning
    % reset also errors when files are deleted between save-load of the datastore
    % to/from MAT-Files (and between releases).
    kvdsCopy = copy(kvds);
    reset(kvdsCopy);

    % If empty files return an empty table with correct VariableNames for the empty
    % empty table
    if isEmptyFiles(kvdsCopy) || ~hasdata(kvdsCopy)
        import matlab.io.datastore.KeyValueDatastore;
        data = emptyTabular(kvdsCopy,KeyValueDatastore.TABLE_OUTPUT_VARIABLE_NAMES);
        return;
    end
    % read all the data
    data =  readAllSplits(kvdsCopy.Splitter);
catch ME
    throw(ME);
end
end
