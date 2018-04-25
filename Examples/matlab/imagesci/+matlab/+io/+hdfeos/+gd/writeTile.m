function writeTile(gridID,fieldName,tilecoords,data)
%writeTile  Write a tile to a field.
%   writeTile(gridID,FIELDNAME,TILECOORDS,DATA) writes a single tile of
%   data to a field.  If the field data can be arranged tile by tile, this
%   routine is more efficient than gd.writeField.  In all other cases, 
%   gd.writeField should be used.  should be used.  TILECOORDS has the 
%   form [ROWNUM COLNUM] and is defined in terms of the tile coordinates, 
%   not the data elements.
%
%   This function corresponds to the GDwritetile function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   tilecoords parameter is reversed with respect to the C library API.
%
%   Example:  Define a field with a 2-by-3 tiling scheme.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       xdim = 200; ydim = 180;
%       gridID = gd.create(gfid,'PolarGrid',xdim,ydim,[],[]);
%       zonecode = 40; 
%       spherecode = 0;
%       projParm = zeros(1,13);
%       projParm(6) =  90000000;
%       gd.defProj(gridID,'ps',[],spherecode,projParm);
%       tileSize = [100 60];
%       gd.defTile(gridID,tileSize);
%       dimlist = {'XDim','YDim'};
%       gd.defField(gridID,'Pressure',dimlist,'int32');
%       for c = 0:2
%           for r = 0:1
%               data = (r+c)*ones(tileSize,'int32');
%               gd.writeTile(gridID,'Pressure',[r c],data);
%           end
%       end
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.readTile.

%   Copyright 2010-2013 The MathWorks, Inc.

% We could query the tile information, 
% would allow us to warn users when they are trying to write 
% out of bounds data.

% Flip tile coords because of majority issue.
tilecoords = fliplr(tilecoords);
status = hdf('GD','writetile',gridID,fieldName,tilecoords,data);
hdfeos_gd_error(status,'GDwritetile');
