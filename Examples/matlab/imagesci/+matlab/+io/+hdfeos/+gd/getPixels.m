function [row,col] = getPixels(gridID,lat,lon)
%getPixels Retrieve pixel rows and columns for lat/lon pairs.
%   [ROW,COL] = getPixels(gridID,LAT,LON) converts lat/lon pairs into
%   zero-based pixel row and column coordinates.  The origin is the upper
%   left-hand corner of the grid pixel.  If the lat/lon pairs are outside
%   the grid, ROW and COL will be -1.
%
%   This function corresponds to the GDgetpixels function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       cornerlat = [20 50];
%       cornerlon = [-90 -60];
%       [row,col] = gd.getPixels(gridID,cornerlat,cornerlon);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.getPixValues.

%   Copyright 2010-2013 The MathWorks, Inc.

% Reverse the row,col parameters to make them match with MATLAB
% conventions.
[col,row,status] = hdf('GD','getpixels',gridID,lon,lat);
hdfeos_gd_error(status,'GDpixels');
