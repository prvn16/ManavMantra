function setTileComp(gridID,fieldName,tileSize,compCode,compParm)
%setTileComp  Set tiling and compression for field with fillvalue.
%   setTileComp(GRIDID,FIELDNAME,TILESIZE,COMPCODE,COMPPARM) sets the
%   tiling and compression for a field that had a fillvalue.  This function
%   must be applied after gd.defField and gd.setFillValue.  COMPCODE can be
%   one of the following strings:
%
%       'rle'     - run length encoding
%       'skphuff' - skipping Huffman
%       'deflate' - deflate
%       'none     - no compression
%
%   compParm need only be specified when the compression scheme is
%   'deflate', and then must be an integer between 0 and 9.
%
%   This function corresponds to the GDsettilecomp function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   tilesize parameter is reversed with respect to the C library API.
%
%   Example:  Define a temperature field with a 2x2 tiling scheme, a fill
%   value of -999, and deflate compression.  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       upleft = [210584.50041 3322395.95445];
%       lowright = [813931.10959 2214162.53278];
%       gridID = gd.create(gfid,'UTMGrid',120,200,upleft,lowright);
%       spherecode = 0; zonecode = 40;
%       projparm = zeros(1,13);
%       gd.defProj(gridID,'utm',zonecode,spherecode,projparm);
%       gd.defDim(gridID,'Time',10);
%       gd.defField(gridID,'Pollution',{'XDim','YDim','Time'},'float');
%       gd.setFillValue(gridID,'Pollution',single(7));
%       gd.setTileComp(gridID,'Pollution',[40 20 1],'deflate',5);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defTile, gd.defComp.

%   Copyright 2010-2013 The MathWorks, Inc.

% Supply default compression parameters if not provided in non-deflate 
% case. 
if strcmpi(compCode,'deflate')
    validateattributes(compParm,{'double'},{'scalar','integer','>=',0,'<=',9},'','DEFLATE LEVEL');
else
    compParm = [];
end

tileSize = fliplr(tileSize);

status = hdf('GD','settilecomp',gridID,fieldName,tileSize,compCode,compParm);
hdfeos_gd_error(status,'GDsettilecomp');
