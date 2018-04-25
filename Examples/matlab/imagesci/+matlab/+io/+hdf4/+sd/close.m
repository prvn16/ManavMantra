function close(sdID)
%close Terminate access to SD interface.
%   sd.close(sdID) closes the file identified by sdID.  
%
%   This function corresponds to the SDend function in the HDF C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.start.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SD','end',sdID);
if status < 0
    hdf4_sd_error('SDend');
end


