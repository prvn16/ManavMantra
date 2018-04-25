function setAttr(objID,name,attrData)
%setAttr Write attribute value.
%   setAttr(objID,NAME,VALUE) attaches an attribute to the object 
%   specified by objID.  If objID is the SD interface identifier, then a
%   global attribute is created.  If a data identifier is specified, then
%   the attribute is attached to the data set.  If a dimension identifier is
%   specified, then the attribute is attached to the dimension.
%
%   This function corresponds to the SDsetattr function in the HDF library
%   C API.
%
%   Example:  Attach attributes to a file, a data set, and to a dimension.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sd.setAttr(sdID,'creation_date',datestr(now));
%       sdsID = sd.create(sdID,'temperature','double',[10 20]);
%       sd.setAttr(sdsID,'long_name','Temperature in sunlight.');
%       dimID0 = sd.getDimID(sdsID,0);
%       sd.setAttr(dimID0,'long_name','latitude');
%       sd.endAccess(sdsID);
%       sd.close(sdID);
% 
%   See also sd, sd.readAttr, sd.findAttr.

%   Copyright 2010-2013 The MathWorks, Inc.


status = hdf('SD','setattr',objID,name,attrData);
if status < 0
    hdf4_sd_error('SDsetattr');
end
