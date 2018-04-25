function scale = getDimScale(dimID)
%getDimScale Return scale data for dimension.
%   SCALE = getDimScale(dimID) returns the scale values of the dimension
%   identified by dimID.
% 
%   This function corresponds to the SDgetdimscale function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',20);
%       dimID = sd.getDimID(sdsID,0);
%       sd.setDimName(dimID,'x');
%       sd.setDimScale(dimID,0:5:95);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%       sdID = sd.start('myfile.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       dimID = sd.getDimID(sdsID,0);
%       scale = sd.getDimScale(dimID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.dimInfo, sd.setDimScale.

%   Copyright 2010-2013 The MathWorks, Inc.

[scale,status] = hdf('SD','getdimscale',dimID);
if status < 0
    hdf4_sd_error('SDgetdimscale');
end
