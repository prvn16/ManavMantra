function data = interpolate(gridID,lat,lon,fieldName)
%interpolate Perform bilinear interpolation on a grid field.
%   DATA = interpolate(GRIDID,LAT,LON,FIELDNAME) performs
%   bilinear interpolation on lat/lon pairs from the data in the grid
%   field.  
%
%   DATA are the interpolated field values.
%
%   This function corresponds to the GDinterpolate function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('example.hdf');
%       gridID = gd.attach(gfid,'MonthlyRain');
%       [lat,lon] = gd.ij2ll(gridID,[36 36],[14 15]);
%       data = gd.interpolate(gridID,lat,lon,'TbOceanRain');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also matlab.io.hdfeos.gd, matlab.io.hdfeos.gd.ij2ll.

%   Copyright 2015 The MathWorks, Inc.

[data,status] = hdf('GD','interpolate',gridID,lon,lat,fieldName);
hdfeos_gd_error(status,'GDinterpolate');

