function [name,count,datatype,nattrs] = dimInfo(dimID)
%dimInfo Return information about dimension.
%   [NAME,DIMLEN,DATATYPE,NATTRS] = dimInfo(dimID) retrieves the name,
%   length, datatype, and number of attributes of the specified dimension.
%
%   This function corresponds to the SDdiminfo function in the HDF library 
%   C API.
%
%   Example:  Read a 2x3 portion of a data set.  
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'latitude');
%       sdsID = sd.select(sdID,idx);
%       dimID = sd.getDimID(sdsID,0);
%       [name,dimlen,datatype,nattrs] = sd.dimInfo(dimID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.getDimID.

%   Copyright 2010-2013 The MathWorks, Inc.

[name,count,datatype,nattrs,status] = hdf('SD','diminfo',dimID);
if status < 0
    hdf4_sd_error('SDdiminfo');
end
