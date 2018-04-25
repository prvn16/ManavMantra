function defComp(swathID,compScheme,compParm)
%defComp Set grid field compression
%   defComp(SWATHID,COMPSCHEME,COMPPARM) sets the field compression
%   for subsequent definitions.  The compression scheme does not apply to
%   one-dimensional fields.  COMPSCHEME can be one of the following 
%   strings:
%
%       'rle'     - run length encoding
%       'skphuff' - skipping Huffman
%       'deflate' - gzip compression
%       'none'    - no compression
%
%   When the compression scheme is 'deflate', COMPPARM is the deflate 
%   compression level, an integer between 0 and 9.  COMPPARM may be
%   omitted for the other compression schemes.
%  
%   Fields defined with compression must be written with a single call to
%   sw.writeField.
%
%   This function corresponds to the SWdefcomp function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'MySwath');
%       sw.defDim(swathID,'Track',4000);
%       sw.defDim(swathID,'Xtrack',2000);
%       sw.defDim(swathID,'Bands',3);
%       sw.defComp(swathID,'rle');
%       dims = {'Xtrack','Track'};
%       sw.defDataField(swathID,'Pressure',dims,'float');
%       sw.defComp(swathID,'deflate',5);
%       sw.defDataField(swathID,'Opacity',dims,'float');
%       sw.defComp(swathID,'skphuff');
%       dims = {'Xtrack','Track','Bands'};
%       sw.defDataField(swathID,'Spectra',dims,'float');
%       sw.defComp(swathID,'none');
%       dims = {'Xtrack','Track'};
%       sw.defDataField(swathID,'Temperature',dims,'float');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.compInfo.

%   Copyright 2010-2015 The MathWorks, Inc.

if nargin < 3
    if strcmpi(compScheme,'deflate')
            error(message('MATLAB:imagesci:hdfeos:missingCompressionParameter'));
    else
        % RLE, SKPHUFF, and NONE can have empty compression parameters.
        compParm = [];
    end
end

% Catch bad deflate levels since the library does not.
if strcmpi(compScheme,'deflate')
    validateattributes(compParm,{'double'},{'scalar','integer','>=',0,'<=',9},'','DEFLATE LEVEL');
end

status = hdf('SW','defcomp',swathID,compScheme,compParm);
hdfeos_sw_error(status,'SWdefcomp');
