function fillValue = getFillValue(sdsID)
%getFillValue Retrieve the fill value for a data set.
%   FILLVALUE = getFillValue(sdsID) retrieves the fill value for a data
%   set.
%
%   This function corresponds to the SDgetfillvalue function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       fillvalue = sd.getFillValue(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%       
%   See also sd, sd.setFillValue.

%   Copyright 2010-2013 The MathWorks, Inc.

[fillValue,status] = hdf('SD','getfillvalue',sdsID);
if status < 0
    hdf4_sd_error('SDgetfillvalue');
end
