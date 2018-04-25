function defPixReg(gridID,pixRegCode)
%defPixReg Define pixel registration within grid.
%   defPixReg(gridID,PIXREGCODE) defines whether the pixel center or
%   pixel corner is used when requesting the location (longitude and
%   latitude) of a given pixel.  PIXREGCODE can be one of the following
%   strings:
%
%       'center' - center of pixel cell
%       'corner' - corner of pixel cell
%
%   If this routine is not invoked, the pixel registration is 'center'.
%
%   This function corresponds to the GDdefpixreg function in the HDF-EOS 
%   library.
%
%   Example:  Define a grid with pixel registration in the center.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       gridID = gd.create(gfid,'PolarGrid',100,100,[],[]);
%       projparm = zeros(1,13);
%       projparm(6) = 90000000;
%       gd.defProj(gridID,'ps',[],'WGS 84',projparm);
%       gd.defPixReg(gridID,'corner');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defOrigin, gd.pixRegInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('GD','defpixreg',gridID,pixRegCode);
hdfeos_gd_error(status,'GDdefpixreg');
