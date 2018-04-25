function [data, info] = read(fds)
%READ Read the next file from the datastore.
%   DATA = READ(FDS) reads the next consecutive file from FDS.
%   DATA is the data returned by the ReadFcn of FileDatastore.
%   READ(FDS) errors if there are no files in FDS and should be used
%   with hasdata(FDS).
%
%   [DATA,INFO] = READ(FDS) also returns a structure with additional
%   information about DATA. The fields of INFO are:
%      Filename - Name of the file from which the data was read
%      FileSize - Size of the file in bytes
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fds = fileDatastore(folder,'ReadFcn',@load,'FileExtensions','.mat');
%
%      while hasdata(fds)
%         data = READ(fds);      % Read one file at a time
%      end
%
%   See also fileDatastore, hasdata, readall, preview, reset.

%   Copyright 2015-2016 The MathWorks, Inc.
try
    [data, info] = readData(fds);
catch e
    throw(e)
end
end
