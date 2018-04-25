function sdsID = select(sdID,idx)
%select Return identifier of data set with specified index.
%   sdsID = select(sdID,IDX) returns the identifier of the data set
%   specified by its index.
%
%   This function corresponds to the SDselect function in the HDF C
%   library.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf','read');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.endAccess, sd.nametoIndex.

%   Copyright 2010-2013 The MathWorks, Inc.

sdsID = hdf('SD','select',sdID,idx);
if sdsID < 0
    hdf4_sd_error('SDselect');
end
