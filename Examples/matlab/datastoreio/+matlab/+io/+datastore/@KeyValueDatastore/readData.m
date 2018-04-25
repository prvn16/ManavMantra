function [data, info] = readData(kvds)
%READDATA Read key-value pairs from a KeyValueDatastore.
%   T = READDATA(KVDS) reads some key-value pairs from KVDS. 
%   T is a table with variables 'Key' and 'Value'.
%   KVDS.ReadSize controls the number of key-value pairs that are
%   read.
%   read(KVDS) errors if there are no more key-value pairs in KVDS,
%   and should be used with hasdata(KVDS).
%
%   [T,info] = READDATA(KVDS) also returns a structure with additional
%   information about KVDS. The fields of info are:
%      FileType - Type of file in KVDS ('mat' or 'seq')
%      Filename - Name of the file from which data was read.
%      FileSize - Size of the file (NumKeyValuePairs for 'mat', bytes for
%                 'seq').
%      Offset   - Start index of data read from file (key-value pair index
%                 for 'mat', position in bytes for 'seq').
%
%   Example:
%   --------
%      % 'mapredout.mat' is the output file of a mapreduce function.
%      kvds = datastore('mapredout.mat')
%      kvds.ReadSize = 3
%      while hasdata(kvds)
%         % read 3 key-value pair at a time
%         kv3 = read(kvds)
%      end
%
%   See also matlab.io.datastore.KeyValueDatastore, hasdata, readall, preview, reset.

%   Copyright 2016 The MathWorks, Inc.
try
    warning('off', 'MATLAB:MatFile:OlderFormat');
    c = onCleanup(@() warning('on', 'MATLAB:MatFile:OlderFormat'));
    [data, info] = readData@matlab.io.datastore.SplittableDatastore(kvds);
catch e
    throw(e)
end
end
