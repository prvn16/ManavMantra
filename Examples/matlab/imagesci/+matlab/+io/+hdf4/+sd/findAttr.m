function idx = findAttr(objID,attrName)
%findAttr Return index of specified attribute.
%   IDX = findAttr(objID,ATTRNAME) returns the index of the attribute
%   specified by ATTRNAME.  objID may be either an SD interface identifier,
%   a data set identifier, or a dimension identifier.
%
%   The function corresponds to the SDfindattr function in the HDF library
%   C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.findAttr(sdID,'creation_date');
%       data = sd.readAttr(sdID,idx);
%       sd.close(sdID);
%
%   See also sd, sd.start, sd.select, sd.getDimID, sd.readAttr.

%   Copyright 2010-2013 The MathWorks, Inc.


idx = hdf('SD','findattr',objID,attrName);
if idx < 0
    hdf4_sd_error('SDfindattr');
end
