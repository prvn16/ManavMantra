function writeChunk(sdsID,fortran_origin,data)
%writeChunk Write chunk to data set.
%   writeChunk(sdsID,ORIGIN,DATACHUNK) writes an entire chunk of data to
%   the data set identified by sdsID.  ORIGIN specifies the location of the
%   chunk in chunking coordinates, not in data set coordinates.
%
%   This function corresponds to the SDwritehunk function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   origin parameter is reversed with respect to the C library API.
%
%   Example:  Write to a 2D chunked and compressed data set. The chunked
%   layout will constitute a 10x5 grid.
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[100 50]);
%       sd.setChunk(sdsID,[10 10],'deflate',5);
%       for j = 0:9
%           for k = 0:4
%               origin = [j k];
%               data = (1:100) + k*1000 + j*10000;
%               data = reshape(data,10,10);
%               sd.writeChunk(sdsID,origin,data);
%           end
%       end
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.readChunk, sd.writeData.

%   Copyright 2010-2013 The MathWorks, Inc.

% Verify that the provided origin makes sense.
chunkDims = matlab.io.hdf4.sd.getChunkInfo(sdsID);
if isempty(chunkDims)
    error(message('MATLAB:imagesci:sd:notChunkedDataSet'));
end
[~,varDims] = matlab.io.hdf4.sd.getInfo(sdsID);
maxOrigin = varDims ./ chunkDims;

if numel(maxOrigin) ~= numel(fortran_origin)
    error(message('MATLAB:imagesci:sd:badWriteChunkOriginLength'));
end
if any(fortran_origin>=maxOrigin)
    error(message('MATLAB:imagesci:sd:badWriteChunkOriginArgument'));
end

c_origin = fliplr(fortran_origin);
status = hdf('SD','writechunk',sdsID,c_origin,data);
if status < 0
    hdf4_sd_error('SDwritechunk');
end
