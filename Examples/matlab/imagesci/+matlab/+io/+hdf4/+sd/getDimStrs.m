function [label, unit, format] = getDimStrs(dimID)
%getDimStrs Retrieve label, unit, and format attribute strings.
%   [LABEL,UNIT,FORMAT] = getDimStrs(dimID) retrieves the label, unit,
%   and format attributes for the dimension identified by dimID.
%
%   This function corresponds to the SDgetdimstrs function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',20);
%       dimID = sd.getDimID(sdsID,0);
%       sd.setDimName(dimID,'x');
%       sd.setDimStrs(dimID,'xdim','none','%d');
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%       sdID = sd.start('myfile.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       dimID = sd.getDimID(sdsID,0);
%       [label,unit,fmt] = sd.getDimStrs(dimID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setDimStrs.

%   Copyright 2010-2013 The MathWorks, Inc.

[label,unit,format,status] = hdf('SD','getdimstrs',dimID);
if status < 0
    hdf4_sd_error('SDgetdimstrs');
end
