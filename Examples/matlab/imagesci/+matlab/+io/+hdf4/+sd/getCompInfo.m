function [compType,compParms] = getCompInfo(sdsID)
%getCompInfo Retrieve data set compression information.
%   [COMPTYPE,COMPPARMS] = getCompType(sdsID) retrieves the compression
%   type and compression information for a data set.  COMPTYPE may be one
%   of the following strings:
%
%       'none'    - no compression
%       'rle'     - run-length encoding
%       'nbit'    - NBIT compression
%       'skphuff' - Skipping Huffman compression
%       'deflate' - GZIP compression
%       'szip'    - SZIP compression
%
%   If COMPTYPE is 'none' or 'rle', then COMPPARMS will be [].
%
%   If COMPTYPE is 'nbit', then COMPPARM is a 4-element array.  
% 
%       COMPPARM(1) - sign_ext
%       COMPPARM(2) - fill_one
%       COMPPARM(3) - start_bit
%       COMPPARM(4) - bit_len
%   
%   If COMPTYPE is 'deflate', then COMPPARMS will contain the deflation 
%   value, a number between 0 and 9.
%
%   If COMPTYPE is 'szip', them COMPPARM is a 5-element array.  You must
%   consult the HDF Reference Manual for details on SZIP compression.
%
%   This function corresponds to the SDgetcompinfo function in the HDF
%   library C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('myfile.hdf','create');
%       sdsID = sd.create(sdID,'temperature','double',[100 50]);
%       sd.setCompress(sdsID,'deflate',5);
%       [comptype,compparm] = sd.getCompInfo(sdsID);
%       sd.endAccess(sdsID);
%       sd.close(sdID);
%
%   See also sd.setCompress, sd.setNBitDataSet.

%   Copyright 2010-2013 The MathWorks, Inc.

[compType,compParms,status] = hdf('SD','getcompinfo',sdsID);
if status < 0 
    hdf4_sd_error('SDgetcompinfo');
end


