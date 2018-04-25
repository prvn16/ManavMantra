function writeBlkSomOffset(gridID,offset)
%writeBlkSomOffset Write Block SOM offset.
%   writeBlkSomOffset(gridID,OFFSET) writes the block SOM offset values 
%   in pixels for a standard Solar Oblique Mercator (SOM) projection.  
%   OFFSET is a vector of offset values for SOM projection data.  This 
%   routine can only be used with grids that use the SOM projection.
%   
%   You must take care to use this function properly in conjunction with
%   gd.defProj.  The 12th element of the projection parameters must be set
%   to the total number of blocks to be defined.  OFFSET starts by listing
%   the offset to the 2nd block, so the 12th element of the projection
%   parameters is always one more than the length of OFFSET.
%
%   All fields defined after writing the block SOM offset values will
%   automatically include "SOMBlockDim" as the slowest varying dimension.
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
%
%   See also gd, gd.readBlkSomOffset.

%   Copyright 2010-2013 The MathWorks, Inc.

% Verify that we have a valid SOM setup before trying to write it.
[projcode,~,~,projparms] = matlab.io.hdfeos.gd.projInfo(gridID);
if ~strcmp(projcode,'som')
    error(message('MATLAB:imagesci:hdfeos:notSomProjection', projcode));
end

if numel(offset) ~= (projparms(12)-1)
    error(message('MATLAB:imagesci:hdfeos:badSomBlockOffsetLength', numel( offset ), projparms( 12 )));
end

status = hdf('GD','blksomoffset',gridID,offset);
hdfeos_gd_error(status,'GDblkSOMoffset');
