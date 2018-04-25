function dimID = getDimID(sdsID,rDimNumber)
%getDimID Retrieve identifier of dimension.
%   dimID = getDimID(sdsID,DIMNUMBER) returns the identifier of the
%   dimension given its index.  
%
%   Note:  MATLAB uses Fortran-style indexing while the HDF library uses
%   C-style indexing.  The order of the dimension identifiers retrieved 
%   with sd.getDimID will be reversed from what would be retrieved via the
%   C API.
%
%   This function corresponds to the SDgetdimid function in the HDF library
%   C API.
%
%   Example:  Read an entire data set.
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       dimID0 = sd.getDimID(sdsID,0);
%       dimID1 = sd.getDimID(sdsID,1);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setDimName.

%   Copyright 2010-2013 The MathWorks, Inc.


[~,dims] = matlab.io.hdf4.sd.getInfo(sdsID);
ndims = numel(dims);
dimNumber = ndims - rDimNumber - 1;
dimID = hdf('SD','getdimid',sdsID,dimNumber);
if dimID < 0
    hdf4_sd_error('SDgetdimid');
end
