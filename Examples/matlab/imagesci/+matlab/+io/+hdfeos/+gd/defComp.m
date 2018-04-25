function defComp(gridID,compScheme,compParm)
%defComp Set grid field compression.
%   defComp(gridID,COMPSCHEME,COMPPARM) sets the HDF field compression
%   for subsequent field definitions.  The compression scheme does not
%   apply to one-dimensional fields.  COMPSCHEME can be one of the
%   following strings:
%
%       'rle'     - run length encoding       
%       'skphuff' - skipping Huffman  
%       'deflate' - gzip deflate         
%       'none'    - no compression      
%
%   When the compression scheme is 'deflate', COMPPARM is the deflate 
%   compression level, an integer between 0 and 9.  COMPPARM may be
%   omitted for the other compression schemes.
%  
%   If a field is defined with compression, it must be written with a
%   single call to gd.writeField.  If this is not possible, you should
%   consider using tiling.
%
%   This function corresponds to the GDdefcomp function in the HDF-EOS
%   library C API.
%
%   Example:  Create a grid with a polar stereographic prPressure field
%   using run length encoding, and then an Opacity field with deflate
%   compression.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       gridID = gd.create(gfid,'PolarGrid',100,100,[],[]);
%       projparm = zeros(1,13);
%       projparm(6) = 90000000;
%       gd.defProj(gridID,'ps',[],'WGS 84',projparm);
%       dims = { 'XDim', 'YDim' };
%       gd.defComp(gridID,'rle');
%       gd.defField(gridID,'Pressure',dims,'float');
%       gd.defComp(gridID,'deflate',5);
%       gd.defField(gridID,'Opacity',dims,'float');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defField, gd.defTile.

%   Copyright 2010-2013 The MathWorks, Inc.

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

status = hdf('GD','defcomp',gridID,compScheme,compParm);
hdfeos_gd_error(status,'GDdefcomp');
