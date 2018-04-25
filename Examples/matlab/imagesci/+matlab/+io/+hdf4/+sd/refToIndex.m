function idx = refToIndex(sdID,ref)
%refToIndex Return index of data set corresponding to reference number.
%   IDX = refToIndex(sdID,REF) returns the index of the data set
%   identified by its reference number REF.  IDX may then be passed to
%   sd.select to obtain a data set identifier.
%
%   This function corresponds to the SDreftoindex function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf','read');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       ref = sd.idToRef(sdsID);
%       idx2 = sd.refToIndex(sdID,ref);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.idToRef, sd.select.

%   Copyright 2010-2013 The MathWorks, Inc.

idx = hdf('SD','reftoindex',sdID,ref);
if idx < 0
    hdf4_sd_error('SDreftoindex');
end
