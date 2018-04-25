function filename = getFilename(sdID)
%getFilename Retrieve name of file.
%   FILENAME = getFilename(sdID) retrieves the name of a file previously 
%   opened with the sd package with identifier sdID.
%
%   This function corresponds to the SDgetfilename function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       filename = sd.getFilename(sdID);
%       sd.close(sdID);
%
%   See also sd, sd.start, sd.getInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

[filename,namelen] = hdf('SD','getfilename',sdID);
if namelen == -1
    hdf4_sd_error('SDgetfilename');
end
