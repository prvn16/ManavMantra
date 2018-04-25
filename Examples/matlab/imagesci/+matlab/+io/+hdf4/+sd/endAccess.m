function endAccess(sdsID)
%endAccess Terminate access to data set.
%   sd.endAccess(sdsID) terminates access to the data set identified by 
%   sdsID.  Failing to call this function after all operations on the
%   specified data set are complete may result in loss of data.
%
%   This function corresponds to the SDendaccess function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.select, sd.close.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SD','endaccess',sdsID);
if status < 0
    hdf4_sd_error('SDendaccess');
end


