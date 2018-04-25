function sync(ncid)
%netcdf.sync Synchronize netCDF dataset to disk.  
%   
%   netcdf.sync(ncid) synchronizes the state of a netCDF dataset to disk.  
%   The netCDF library will normally buffer accesses to the underlying
%   netCDF file unless the NC_SHARE mode is supplied to netcdf.open or
%   netcdf.create.
%
%   This function corresponds to the "nc_sync" function in the netCDF 
%   library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.open, netcdf.create, netcdf.close, 
%   netcdf.endDef.

%   Copyright 2008-2013 The MathWorks, Inc.

narginchk(1,1);
netcdflib('sync', ncid);            



