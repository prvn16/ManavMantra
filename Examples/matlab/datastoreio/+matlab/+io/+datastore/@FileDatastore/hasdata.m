function tf = hasdata(fds)
%HASDATA Returns true if there is unread data in the FileDatastore.
%   TF = HASDATA(FDS) returns true if the datastore has one or more files
%   available to read with the read method. read(FDS) returns an error
%   when HASDATA(FDS) returns false.
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fds = fileDatastore(folder,'ReadFcn',@load,'FileExtensions','.mat');
%
%      while HASDATA(fds)
%         data = read(fds);      % Read one file at a time
%      end
%
%   See also fileDatastore, read, readall, preview, reset.

%   Copyright 2015 The MathWorks, Inc.
try
    tf = hasdata@matlab.io.datastore.FileBasedDatastore(fds);
catch e
    throw(e);
end
end
