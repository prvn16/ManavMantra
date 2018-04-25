function ref = idToRef(sdsID)
%idToRef Return reference number corresponding to data set identifier.
%   REF = idToRef(sdsID) returns the reference number corresponding to
%   the data set.
%
%   This function corresponds to the SDidtoref function in the HDF library
%   C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       ref = sd.idToRef(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.refToIndex, hdfv.

%   Copyright 2010-2013 The MathWorks, Inc.

ref = hdf('SD','idtoref',sdsID);
if ref < 0
    hdf4_sd_error('SDidtoref');
end
