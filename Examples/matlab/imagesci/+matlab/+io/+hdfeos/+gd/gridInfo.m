function [xdimsize,ydimsize,upleft,lowright] = gridInfo(gridID) 
%gridInfo Return position and size of grid.
%   [XDIM,YDIM,UPLEFT,LOWRIGHT] = gridInfo(gridID) returns the size of
%   a grid as well as the upper left and lower right corners of the grid.
%    
%   Note:  UPLEFT and LOWRIGHT are in units of meters for all GCTP
%   projections other than the geographic and bcea projections, which
%   will have units of packed degrees.
%
%   This function corresponds to the GDgridinfo function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [xdimsize,ydimsize,upleft,lowright] = gd.gridInfo(gridID);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.create.

%   Copyright 2010-2013 The MathWorks, Inc.

[xdimsize,ydimsize,upleft,lowright,status] = hdf('GD','gridinfo',gridID);
hdfeos_gd_error(status,'GDgridinfo');
