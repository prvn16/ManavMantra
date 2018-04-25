function setFillValue(sdsID,fillvalue)
%setFillValue Set the fill value for a data set.
%   setFillValue(sdsID,FILLVALUE) sets the fill value for a data set.  
%   The fill value must have the same datatype as the data set.
%
%   This function corresponds to the SDsetfillvalue function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       sd.setFillValue(sdsID,-999);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.getFillValue.

%   Copyright 2010-2013 The MathWorks, Inc.

validateattributes(fillvalue,{'numeric','char'},{'scalar'},'sd.setFillValue','FILLVALUE');

status = hdf('SD','setfillvalue',sdsID,fillvalue);
if status < 0
    hdf4_sd_error('SDsetfillvalue');
end
