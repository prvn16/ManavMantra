function reset(fds)
%RESET Reset the datastore to the start of the data.
%   RESET(FDS) resets FDS to the beginning of the datastore.
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fds = fileDatastore(folder,'ReadFcn',@load,'FileExtensions','.mat');
%
%      while hasdata(fds)
%          data = read(fds);     % Read the files
%      end
%      RESET(fds);               % Reset to the beginning of the datastore
%      data = read(fds);         % Read from the beginning
%
%   See also fileDatastore, read, readall, hasdata, preview.

%   Copyright 2015 The MathWorks, Inc.
try
    reset@matlab.io.datastore.FileBasedDatastore(fds);
catch ME
    throw(ME);
end
end
