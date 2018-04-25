function offset = readBlkSomOffset(gridID)
%readBlkSomOffset Read Block SOM offset.
%   OFFSET = readBlkSomOffset(GID) reads the block SOM offset values, 
%   in pixels, from a standard SOM (Space Oblique Mercator) projection. 
%   OFFSET is a vector of offset values for SOM projection data.  This 
%   routine can only be used with grids that use the SOM projection.
%
%   This function corresponds to the GDblkSOMoffset function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       lowright = [30521379.68485 1152027.64253];
%       upleft = [-11119487.42844 8673539.24806];
%       gridID = gd.create(gfid,'SOM',120,60,upleft,lowright);
%       projparm(1) = 6378137;
%       projparm(2) = 0.006694348;
%       projparm(4) = 98096360;  % 98.161 in DDDMMMSSS
%       projparm(5) = 87069061;  % 87.112 in DDDMMMSSS
%       projparm(9) = 0.068585416*1440;
%       projparm(10) = 0.0;
%       projparm(12) = 6;
%       gd.defProj(gridID,'som',[],[],projparm);
%       gd.writeBlkSomOffset(gridID,[5 10 12 8 2]);
%       gd.detach(gridID);
%       gd.close(gfid);
%       gfid = gd.open('myfile.hdf');
%       gridID = gd.attach(gfid,'SOM');
%       blk = gd.readBlkSomOffset(gridID);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also:  gd, gd.writeBlkSomOffset.

%   Copyright 2010-2013 The MathWorks, Inc.

% Verify that we have a valid SOM setup before trying to read from it.
projcode = matlab.io.hdfeos.gd.projInfo(gridID);
if ~strcmp(projcode,'som')
    error(message('MATLAB:imagesci:hdfeos:notBlockSomProjection', projcode));
end

[offset,status] = hdf('GD','readblksomoffset',gridID);
hdfeos_gd_error(status,'GDreadblkSOMoffset');
