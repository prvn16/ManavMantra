function defTile(gridID,tileDims)
%defTile Define tiling parameters.
%   defTile(GID,TILEDIMS) defines tiling dimensions for subsequent 
%   field definitions.  IF TILEDIMS is [], then subsequently defined 
%   fields will have no tiling.
%
%   This function corresponds to the GDdeftile function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   tileDims parameter is reversed with respect to the C library API.
%
%   Example:  Define a field with tiling, then a subsequent field with no 
%   tiling.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       gridID = gd.create(gfid,'GeoGrid',120,200,[],[]);
%       gd.defDim(gridID,'Bands',3);
%       gd.defProj(gridID,'geo',[],[],[]);
%       gd.defTile(gridID,[30 50 1]);
%       dimlist = {'XDim','YDim','Bands'};
%       gd.defField(gridID,'Spectra',dimlist,'float');
%       gd.defTile(gridID,[]);
%       dimlist = {'XDim','YDim'};
%       gd.defField(gridID,'Temperature',dimlist,'int32');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.tileInfo, gd.defField.

%   Copyright 2010-2013 The MathWorks, Inc.

if isempty(tileDims)
    tileCode = 'notile';
else
    tileCode = 'tile';
end

% Flip the tile dimensions because of majority issue.
tileDims = fliplr(tileDims);
status = hdf('GD','deftile',gridID,tileCode,tileDims);
hdfeos_gd_error(status,'GDdeftile');
