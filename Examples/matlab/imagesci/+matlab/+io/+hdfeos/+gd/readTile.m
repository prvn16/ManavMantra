function data = readTile(gridID,fieldName,tilecoords)
%readTile Read single tile of data from field.
%   data = readTile(gridID,FIELDNAME,TILECOORDS) reads a single of data
%   from a field.  If the data is to be read tile by tile, this routine is
%   more efficient than gd.readField.  In all other cases, gd.readField 
%   should be used.  TILECOORDS has the form [ROWNUM COLNUM] and is 
%   defined in terms of the tile coordinates, not the data elements.
%
%   This function corresponds to the GDreadtile function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   tilecoords parameter is reversed with respect to the C library API.
%
%   Example:  Define a field with a 2-by-3 tiling scheme.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       for h = 0:9
%           data = gd.readTile(gridID,'pressure',[0 0 h]);
%       end
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.writeTile, gd.tileInfo.

%   Copyright 2010-2015 The MathWorks, Inc.
%

tiledims = matlab.io.hdfeos.gd.tileInfo(gridID,fieldName);
if isempty(tiledims)
    error(message('MATLAB:imagesci:hdfeos:readFieldNotTiled', fieldName));
end

tilecoords = fliplr(tilecoords);
[data, status] = hdf('GD','readtile',gridID,fieldName,tilecoords);
hdfeos_gd_error(status,'GDreadtile');

% readtile will read the data as a single column.  We need to
% reshape it to the proper size.
tiledims = matlab.io.hdfeos.gd.tileInfo(gridID,fieldName);
data = reshape(data,tiledims);
