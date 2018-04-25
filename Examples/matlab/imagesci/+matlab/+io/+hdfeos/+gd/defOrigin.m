function defOrigin(gridID,originCode)
%defOrigin Define origin of pixels in grid.
%   defOrigin(GID,ORIGINCODE) defines the origin of pixels in a grid. 
%   GID is the identifier of the grid, and ORIGINCODE can be one of the 
%   following four strings.
%
%       'ul' - upper-left
%       'ur' - upper-right
%       'll' - lower-left
%       'lr' - lower-right
%
%   You may select any corner of the grid pixel as the origin.  If this
%   routine is not invoked, the grid will default to using the upper-left
%   corner for the origin.
%
%   This function corresponds to the GDdeforigin function in the HDF-EOS 
%   library C API.
%
%   Example:  Create a polar stereographic grid with the origin of the grid
%   pixel in the lower right corner.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       gridID = gd.create(gfid,'PolarGrid',100,100,[],[]);
%       projparm = zeros(1,13);
%       projparm(6) = 90000000;
%       gd.defProj(gridID,'ps',[],'WGS 84',projparm);
%       gd.defOrigin(gridID,'lr');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.originInfo, gd.defPixReg.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('GD','deforigin',gridID,originCode);
hdfeos_gd_error(status,'GDorigin');
