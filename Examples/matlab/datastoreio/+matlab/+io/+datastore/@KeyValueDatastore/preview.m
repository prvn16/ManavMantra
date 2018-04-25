function data = preview(kvds)
%PREVIEW Read key-value pairs from the start of a KeyValueDatastore.
%   T = PREVIEW(KVDS) reads key-value pairs from the beginning of KVDS.
%   T is a table with variables 'Key' and 'Value'.
%   KVDS.ReadSize controls the number of key-value pairs that are read.
%   PREVIEW does not affect the state of KVDS.
%
%   Example:
%   --------
%      % 'mapredout.mat' is the output file of a mapreduce function.
%      kvds = datastore('mapredout.mat')
%      kvds.ReadSize = 3
%      % PREVIEW 3 key-value pairs
%      kv3 = PREVIEW(kvds)
%
%   See also matlab.io.datastore.KeyValueDatastore, hasdata, readall, read, reset.

%   Copyright 2014-2016 The MathWorks, Inc.

try
    % If files are empty, use READALL to get the correct empty table
    if isEmptyFiles(kvds)
        data = readall(kvds);
        return;
    end
    kvdsCopy = copy(kvds);
    reset(kvdsCopy);
    warning('off', 'MATLAB:MatFile:OlderFormat');
    c = onCleanup(@() warning('on', 'MATLAB:MatFile:OlderFormat'));
    data = read(kvdsCopy);
catch e
    throw(e);
end
end
