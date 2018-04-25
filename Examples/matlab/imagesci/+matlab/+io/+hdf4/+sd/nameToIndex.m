function idx = nameToIndex(sdID,sdsName)
%nameToIndex Return index value of named data set.
%   IDX = nameToIndex(sdID,SDSNAME) returns the index of the data set
%   with the name specified by SDSNAME.  If there is more than one data set
%   with the same name, the routine will return the index of the first one.
%
%   This function corresponds to the SDnametoindex function in the HDF C
%   API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf','read');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sd.close(sdID);
%
%   See also sd, sd.select.

%   Copyright 2010-2013 The MathWorks, Inc.

idx = hdf('SD','nametoindex',sdID,sdsName);
if idx < 0
    hdf4_sd_error('SDnametoindex');
end


