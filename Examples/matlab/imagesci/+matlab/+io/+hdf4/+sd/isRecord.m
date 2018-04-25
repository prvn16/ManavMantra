function tf = isRecord(sdsID)
%isRecord Determine if a data set is appendable.
%   TF = isRecord(sdsID) will determine if the data set specified by
%   sdsID is appendable, meaning that the slowest changing dimension is
%   unlimited.
%
%   This function corresponds to the SDisrecord function in the HDF library
%   C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       ndataset = sd.fileInfo(sdID);
%       for idx = 0:ndataset-1
%           sdsID = sd.select(sdID,idx);
%           sdsName = sd.getInfo(sdsID);
%           if sd.isRecord(sdsID)
%               fprintf('%s is a record variable.\n',sdsName);
%           else
%               fprintf('%s is not a record variable.\n',sdsName);
%           end
%           sd.endAccess(sdsID);
%       end
%       sd.close(sdID);
%
%   See also sd, sd.isCoordVar.

%   Copyright 2010-2013 The MathWorks, Inc.

val = hdf('SD','isrecord',sdsID);
if val > 0
    tf = true;
else
    tf = false;
end
