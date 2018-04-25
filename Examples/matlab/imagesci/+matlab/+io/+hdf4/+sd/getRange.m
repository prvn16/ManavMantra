function [maxval,minval] = getRange(sdsID)
%getRange Retrieve maximum and minimum values of range.
%   [MAXVAL,MINVAL] = getRange(sdsID) retrieves the "valid_range"
%   two-element attribute value.
%
%   This function corresponds to the SDgetrange function in the HDF library
%   C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       [maxval,minval] = sd.getRange(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%   
%   See also sd, sd.setRange.

%   Copyright 2010-2013 The MathWorks, Inc.

[maxval, minval, status] = hdf('SD','getrange',sdsID);
if status < 0
    hdf4_sd_error('SDgetrange');
end
