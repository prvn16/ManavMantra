function chunkDims = getChunkInfo(sdsID)
%getChunkInfo Retrieve chunksize for data set.
%   CHUNKDIMS = getChunkInfo(sdsID) retrieves the chunk size for the
%   data set specified by sdsID.  If a data set is chunked, the dimensions
%   of the chunks is returned in CHUNKDIMS.  Otherwise CHUNKDIMS is [].
%
%   This function corresponds to the SDgetchunkinfo function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   chunkDims parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.nameToIndex(sdID,'temperature');
%       sdsID = sd.select(sdID,idx);
%       cdims = sd.getChunkInfo(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setChunk, sd.getCompInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

[~,dims] = matlab.io.hdf4.sd.getInfo(sdsID);
if isempty(dims)
    % Gets around singleton case.
    chunkDims = [];
    return
end

[chunkDims,isChunked,isChunkedCompressed,status] = hdf('SD','getchunkinfo',sdsID);
if status < 0 
    hdf4_sd_error('SDgetchunkinfo');
end

chunkDims = fliplr(chunkDims);

if ~(isChunked || isChunkedCompressed)
    chunkDims = [];
end
    

