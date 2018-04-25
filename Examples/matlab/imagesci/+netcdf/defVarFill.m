function defVarFill(ncid,varid,noFillMode,fillvalue)
%netcdf.defVarFill Sets fill parameters for a variable in a netCDF-4 file.
%   netcdf.defVarFill(ncid,varid,noFillMode,fillValue) sets the fill 
%   parameters for a netCDF variable identified by varid.  ncid specifies 
%   the location.  fillValue must be the same datatype as the variable.
%
%   When noFillMode is set to true, fill values will not be written for the
%   variable and any value supplied for fillValue will be ignored. This is
%   helpful in high performance applications.  This should never be done
%   after calling netcdf.endDef.
%
%   This function corresponds to the "nc_def_var_fill" function in the 
%   netCDF library C API.  
%
%   Example:
%       ncid = netcdf.create('myfile.nc','NETCDF4');
%       dimid =  netcdf.defDim(ncid,'latitude',180);
%       varid = netcdf.defVar(ncid,'latitude','double',dimid);
%       netcdf.defVarFill(ncid,varid,false,-999);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.setFill, netcdf.inqVarFill.

%   Copyright 2010-2016 The MathWorks, Inc.

netcdflib('defVarFill',ncid,varid,noFillMode,fillvalue);
