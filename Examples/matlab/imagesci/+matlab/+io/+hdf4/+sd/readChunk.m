function data = readChunk(sdsID,origin)
%readChunk Read chunk from data set.
%   DATACHUNK = readChunk(sdsID,ORIGIN) reads an entire chunk of data
%   from the data set identified by sdsID.  ORIGIN specifies the location
%   of the chunk in zero-based chunking coordinates, not in data set
%   coordinates.
%
%   This function corresponds to the SDreadchunk function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   origin parameter is reversed with respect to the C library API.
%
%   Example:  
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       dataChunk = sd.readChunk(sdsID,[0 1]);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.writeChunk, sd.writeData.

%   Copyright 2010-2013 The MathWorks, Inc.

origin = fliplr(origin);
[data, status] = hdf('SD','readchunk',sdsID,origin);
if status < 0
    hdf4_sd_error('SDreadchunk');
end
