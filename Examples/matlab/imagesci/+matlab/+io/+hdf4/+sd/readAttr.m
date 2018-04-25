function data = readAttr(objID,idx)
%readAttr Read attribute value.
%   DATA = readAttr(objID,IDX) reads the value of the attribute
%   specified by index IDX.  objID can be an SD interface identifier, a
%   data set identifier, or a dimension identifier.  IDX is a zero-based
%   index.
%
%   This function corresponds to the SDreadattr function in the HDF library
%   C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.findAttr(sdID,'creation_date');
%       data = sd.readAttr(sdID,idx);
%       sd.close(sdID);
%
%   See also sd, sd.findAttr, sd.setAttr.

%   Copyright 2010-2013 The MathWorks, Inc.


[data,status] = hdf('SD','readattr',objID,idx);
if status < 0
    hdf4_sd_error('SDreadattr');
end
