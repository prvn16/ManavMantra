function [name,dims,datatype,nattrs] = getInfo(sdsID)
%getInfo Return information about data set.
%   [NAME,DIMS,DATATYPE,NATTRS] = getInfo(sdsID) retrieves the name,
%   extents, and number of attributes of the data set identified by sdsID.
%
%   This function corresponds to the SDgetinfo function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   dims parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       [name,dims,datatype,nattrs] = sd.getInfo(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
% 
%   See also sd, sd.dimInfo, sd.attrInfo, sd.fileInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

[name,~,dims,datatype,nattrs,status] = hdf('SD','getinfo',sdsID);
if status < 0
    hdf4_sd_error('SDgetinfo');
end

dims = fliplr(dims);
