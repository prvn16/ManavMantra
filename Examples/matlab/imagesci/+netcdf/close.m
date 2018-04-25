function close(ncid)
%netcdf.close Close netCDF file.
%   netcdf.close(ncid) terminates access to the netCDF file identified
%   by ncid.
%
%   This function corresponds to the "nc_close" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.open, netcdf.create.

%   Copyright 2008-2013 The MathWorks, Inc.

netcdflib('close', ncid);            
