function [row, col] = ll2ij(gridID,lat,lon)
%ll2ij Convert lat/lon coordinates to row/column.
%   [ROW,COL] = ll2ij(gridID,LAT,LON) converts latitude and longitude
%   coordinates to a pre-defined grid's row and column coordinates.
% 
%   ROW and COL are zero-based and defined such that COL increases
%   monotonically with the XDim dimension and ROW increases monotonically
%   with the YDim dimension in the HD-EOS library.
%
%   This routine corresponds to the GDll2ij function in the HDF-EOS C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       lat = [46 46 42 42];
%       lon = [-71 -67 -67 -71];
%       [row,col] = gd.ll2ij(gridID,lat,lon);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.ij2ll.

%   Copyright 2010-2014 The MathWorks, Inc.

[row,col,~,~,status] = hdf('GD','ll2ij',gridID,lon,lat);
hdfeos_gd_error(status,'GDll2ij');
