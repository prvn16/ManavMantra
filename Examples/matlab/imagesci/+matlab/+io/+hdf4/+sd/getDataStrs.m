function [label, unit, format, coordsys] = getDataStrs(sdsID,maxlen)
%getDataStrs Retrieve predefined attribute strings for data set.
%   [LABEL,UNIT,FORMAT,COORDSYS] = getDataStrs(sdsID) retrieves 
%   the label, unit, format, and coordsys attributes for the data set 
%   identified by sdsID.  
%
%   [LABEL,UNIT,FORMAT,COORDSYS] = getDataStrs(sdsID,MAXLEN) retrieves 
%   the label, unit, format, and coordsys attributes for the data set 
%   identified by sdsID.  MAXLEN is the maximum length of any of the
%   attribute strings.  It defaults to 1000 if not specified.
%
%   This function corresponds to the SDgetdatastrs function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       [label,unit,fmt,coordsys] = sd.getDataStrs(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setDataStrs.

%   Copyright 2010-2013 The MathWorks, Inc.

if nargin < 2
    maxlen = 1000;
end
[label,unit,format,coordsys,status] = hdf('SD','getdatastrs',sdsID,maxlen);
if status < 0
    hdf4_sd_error('SDgetdatastrs');
end
