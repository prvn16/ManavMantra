function [lat, lon] = ij2ll(gridID,row,col)
%ij2ll Convert row/column space to lat/lon.
%   [LAT, LON] = ij2ll(gridID,ROW,COL) converts a grid's row and column 
%   coordinates to latitude and longitude in decimal degrees.  
%
%   ROW and COL are zero-based and defined such that COL increases
%   monotonically with the XDim dimension and ROW increases monotonically
%   with the YDim dimension in the HD-EOS library.
%
%   This routine corresponds to the GDij2ll function in the HDF-EOS C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [xdim,ydim] = gd.gridInfo(gridID);
%       r = 0:(xdim-1);
%       c = 0:(ydim-1);
%       [Col,Row] = meshgrid(c,r);
%       [lat,lon] = gd.ij2ll(gridID,Row,Col);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.ll2ij, gd.readField.

%   Copyright 2010-2013 The MathWorks, Inc.

[xdim,ydim] = matlab.io.hdfeos.gd.gridInfo(gridID);
if any(row(:)<0) || any(row(:)>=xdim) || any(col(:)<0) || any(col(:)>=ydim)
    error(message('MATLAB:imagesci:hdfeos:rowColIndicesOutOfBounds', xdim - 1, ydim - 1));
end


% Rows and columns have reversed meaning in HDF-EOS and in MATLAB.
[lon,lat,status] = hdf('GD','ij2ll',gridID,col,row);
hdfeos_gd_error(status,'GDij2ll');
