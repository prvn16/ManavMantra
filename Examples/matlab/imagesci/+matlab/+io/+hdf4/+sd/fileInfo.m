function [ndatasets,ngatts] = fileInfo(sdID)
%fileInfo Return number of data sets and global attributes in file.
%   [NDATASETS,NGATTS] = fileInfo(sdID) returns the number of data sets
%   NDATASETS and the number of global attributes NGATTS in the file
%   identified by sdID.  
%
%   NDATASETS includes the number of coordinate variable data sets.  
%
%   This function corresponds to the SDfileinfo function in the HDF library
%   C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       [ndatasets,ngatts] = sd.fileInfo(sdID);
%       sd.close(sdID);
%
%   See also sd, sd.getInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

[ndatasets,ngatts,status] = hdf('SD','fileinfo',sdID);
if status < 0
    hdf4_sd_error('SDfileinfo');
end
