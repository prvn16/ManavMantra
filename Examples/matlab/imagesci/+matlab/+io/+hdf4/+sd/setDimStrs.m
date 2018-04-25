function setDimStrs(dimID,label,unit,format)
%setDimStrs Set label, unit, and format attribute strings.
%   setDimStrs(dimID,LABEL,UNIT,FORMAT) sets the label, unit, and format
%   attributes for the dimension identified by dimID.
%
%   This function corresponds to the SDsetdimstrs function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       dimID = sd.getDimID(sdsID,0);
%       sd.setDimName(dimID,'lat');
%       dimID = sd.getDimID(sdsID,1);
%       sd.setDimName(dimID,'lon');
%       sd.setDimStrs(dimID,'Degrees of Longitude','degrees_east','%.2f');
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.getDimStrs.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('SD','setdimstrs',dimID,label,unit,format);
if status < 0
    hdf4_sd_error('SDsetdimstrs');
end
