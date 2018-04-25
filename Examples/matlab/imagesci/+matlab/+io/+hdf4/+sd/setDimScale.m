function setDimScale(dimID,scaleData)
%setDimScale Set scale values for dimension.
%   setDimScale(dimID,SCALEDATA) sets the scale values for a dimension.
%   
%   This function corresponds to the SDsetdimscale function in the HDF
%   library C API.
%
%   Example:  Create a 2D data set with dimensions 'lat' and 'lon'.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       dimID = sd.getDimID(sdsID,0);
%       sd.setDimName(dimID,'lat');
%       sd.setDimScale(dimID,0:10:90);
%       dimID = sd.getDimID(sdsID,1);
%       sd.setDimName(dimID,'lon');
%       sd.setDimScale(dimID, -180:18:179);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.getDimScale.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SD','setdimscale',dimID,scaleData);
if status < 0
    hdf4_sd_error('SDsetdimscale');
end
