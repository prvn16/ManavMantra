function setCompress(sdsID,compType,compParm)
%setCompress Set compression method of data set.
%   setCompress(sdsID,COMPTYPE,COMPPARM) sets the compression scheme for
%   the specified data set.  The compression must be done before writing 
%   the data set.  COMPTYPE may be given by one of the following strings:
%
%       'none'    - no compression 
%       'skphuff' - Skipping Huffman compression
%       'deflate' - gzip compression
%       'rle'     - RLE run-length encoding
%
%   If COMPTYPE is 'none' or 'rle', then COMPPARM need not be specified.  If
%   COMPTYPE is 'skphuff', then COMPPARM is the skipping size.  If COMPTYPE
%   is 'deflate', then COMPPARM is the deflate level, which must be between
%   0 and 9.  
%
%   This function corresponds to the SDsetcompress function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[200 100]);
%       sd.setCompress(sdsID,'deflate',5);
%       data = rand(200,100);
%       sd.writeData(sdsID,[0 0],data);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd, sd.setChunk.

%   Copyright 2010-2013 The MathWorks, Inc.

compType = validatestring(compType,{'none','rle','deflate','skphuff'});
switch (compType)
    case {'none', 'rle'}
        status = hdf('SD','setcompress',sdsID,compType);
        
    case 'deflate'
        status = hdf('SD','setcompress',sdsID,compType, ...
            'deflate_level',compParm);

    case 'skphuff'
        status = hdf('SD','setcompress',sdsID,compType, ...
            'skphuff_skp_size',compParm);
        
end
        

if status < 0
    hdf4_sd_error('SDsetcompress');
end
