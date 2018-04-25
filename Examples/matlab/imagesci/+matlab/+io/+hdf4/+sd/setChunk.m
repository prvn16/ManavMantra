function setChunk(sdsID,chunkDims,compType,compParm)
%setChunk Set chunk size and compression method of data set.
%   setChunk(sdsID,CHUNKSIZE,COMPTYPE,COMPPARM) makes the data set
%   specified by sdsID a chunked data set with chunk size given by 
%   CHUNKSIZE and compression specified by COMPTYPE and COMPPARM.  COMPTYPE
%   may be given by one of the following strings:
%
%       'none'    - no compression 
%       'skphuff' - Skipping Huffman compression
%       'deflate' - gzip compression
%       'rle'     - RLE run-length encoding
%
%   If COMPTYPE is 'none' or 'rle', then COMPPARM need not be specified.
%   If COMPTYPE is 'skphuff', then COMPPARM is the skipping size.  If
%   COMPTYPE is 'deflate', then COMPPARM is the deflate level, which must
%   be between 0 and 9.
%
%   This function corresponds to the SDsetchunk function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   CHUNKSIZE parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[200 100]);
%       sd.setChunk(sdsID,[20 10],'skphuff',16);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.readChunk, sd.writeChunk.

%   Copyright 2010-2013 The MathWorks, Inc.

[~,dims] = matlab.io.hdf4.sd.getInfo(sdsID);
if numel(dims) ~= numel(chunkDims)
    error(message('MATLAB:imagesci:sd:badChunkLength'));
end

if any(chunkDims > dims)
    error(message('MATLAB:imagesci:sd:badChunkSize'));
end

chunkDims = fliplr(chunkDims);

compType = validatestring(compType,{'none','rle','deflate','skphuff'});
switch (compType)
    case {'none', 'rle'}
        status = hdf('SD','setchunk',sdsID,chunkDims,compType);
        
    case 'deflate'
        status = hdf('SD','setchunk',sdsID,chunkDims,compType, ...
            'deflate_level',compParm);

    case 'skphuff'
        status = hdf('SD','setchunk',sdsID,chunkDims,compType, ...
            'skphuff_skp_size',compParm);
        
end
        

if status < 0
    hdf4_sd_error('SDsetchunk');
end
