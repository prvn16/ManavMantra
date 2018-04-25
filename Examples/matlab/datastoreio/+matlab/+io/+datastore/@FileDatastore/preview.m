function data = preview(fds)
%PREVIEW Read the first file from the datastore.
%   DATA = PREVIEW(FDS) always reads the first file from FDS.
%   DATA is equal to the data returned by ReadFcn of FileDatastore.
%
%   Example:
%   --------
%      folder = fullfile(matlabroot,'toolbox','matlab','demos');
%      fds = fileDatastore(folder,'ReadFcn',@load,'FileExtensions','.mat');
%
%      PREVIEW(fds);      %Preview the first file
%
%   See also fileDatastore, hasdata, readall, read, reset.

%   Copyright 2015-2017 The MathWorks, Inc.

try
    % If files are empty, return empty cell
    if isEmptyFiles(fds)
        data = fds.BufferedZero1DimData;
        return;
    end
    fdsCopy = copy(fds);
    reset(fdsCopy);
    data = read(fdsCopy);
catch e
    throw(e);
end
end
