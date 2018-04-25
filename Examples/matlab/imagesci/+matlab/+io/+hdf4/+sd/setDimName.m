function setDimName(dimID,name)
%setDimName  Associate a name with dimension.
%   setDimName(dimID,DIMNAME) sets the name of the dimension identified
%   by dimID to DIMNAME.
%
%   This function corresponds to the SDsetdimname function in the HDF
%   library C API.
%
%   Example:  Create a 2D data set with dimensions 'lat' and 'lon'.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       dimID = sd.getDimID(sdsID,0);
%       sd.setDimName(dimID,'lat');
%       dimID = sd.getDimID(sdsID,1);
%       sd.setDimName(dimID,'lon');
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.dimInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SD','setdimname',dimID,name);
if status < 0
    hdf4_sd_error('SDsetdimname');
end
