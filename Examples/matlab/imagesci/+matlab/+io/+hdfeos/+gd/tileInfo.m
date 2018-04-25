function tiledims = tileInfo(gridID,fieldName)
%tileInfo Retrieve tile size of grid field.
%   TILEDIMS = tileInfo(gridID,FIELDNAME) returns the tile dimensions
%   of the field specified by FIELDNAME in the grid specified by gridID.  
%   If the field is not tiled, TILEDIMS will be [].
%
%   This function corresponds to the GDtileinfo function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   tiledims parameter is reversed with respect to the C library API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       tileDims = gd.tileInfo(gridID,'pressure');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defTile.

%   Copyright 2010-2013 The MathWorks, Inc.

[~,tiledims,tilerank,status] = hdf('GD','tileinfo',gridID,fieldName);
hdfeos_gd_error(status,'GDtileinfo');

if tilerank == 0
    tiledims = [];
end

tiledims = fliplr(tiledims);
