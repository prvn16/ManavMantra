function gridID = create(gfid,gridname,xdimsize,ydimsize,upleft,lowright)
%create Create new grid structure.
%   gridID = create(gfID,GRIDNAME,XDIM,YDIM,UPLEFT,LOWRIGHT) creates a
%   new grid structure where GFID is the grid file identifier. GRIDNAME is
%   the name of the new grid.  XDIM and YDIM define the size of the grid.
%   UPLEFT is a two-element vector containing the location of the upper
%   left pixel, and LOWRIGHT is a two-element vector containing the
%   location of the lower right pixel.
%
%   Note:  UPLEFT and LOWRIGHT are in units of meters for all GCTP
%   projections other than the geographic and bcea projections, which
%   should have units of packed degrees.
%
%   Note:  For certain projections, UPLEFT and LOWRIGHT can be given as [].  
%
%       1) Polar Stereographic projection of an entire hemisphere.
%       2) Goode Homolosine projection of the entire globe.
%       3) Lambert Azimuthal entire polar or equatorial projection. 
%   
%   Note:  MATLAB uses Fortran-style ordering, but the HDF-EOS library uses 
%   C-style ordering.  
%
%   This function corresponds to the GDcreate function in the HDF-EOS
%   library C API.
%       
%   Example:  Create a polar stereographic grid of the northern hemisphere.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       gridID = gd.create(gfid,'PolarGrid',100,100,[],[]);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   Example:  Create a UTM grid bounded by 54 E to 60 E longitude and 20 N
%   to 30 N latitude.  Divide the grid into 120 bins along the x-axis and
%   200 bins along the y-axis.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       uplft = [210584.50041 3322395.95445];
%       lowrgt = [813931.10959 2214162.53278];
%       gridID = gd.create(gfid,'UTMGrid',120,200,uplft,lowrgt);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.detach, gd.defProj, gd.gridInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

gridID = hdf('GD','create',gfid,gridname,xdimsize,ydimsize,upleft,lowright);
hdfeos_gd_error(gridID,'GDcreate');
