function oldMode = setFill(ncid,newMode)
%netcdf.setFill Set netCDF fill mode.
%   oldMode = netcdf.setFill(ncid,newMode) sets the fill mode for a 
%   netCDF file.  newMode can be either 'FILL' or 'NOFILL' or their 
%   numeric equivalents as retrieved by netcdf.getConstant.  The default 
%   mode is 'FILL'.  The old fill mode is returned in oldMode.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide".  This function 
%   corresponds to the "nc_set_fill" function in the netCDF library C API.
%
%   Example:
%       ncid = netcdf.create('myfile.nc','CLOBBER');
%       netcdf.setFill(ncid,'NOFILL');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVarFill, netcdf.inqVarFill, 
%   netcdf.getConstant.
%

%   Copyright 2008-2013 The MathWorks, Inc.

if ischar(newMode)
    % Convert the character value to a numeric value.
    newMode = netcdf.getConstant(newMode);
end

oldMode = netcdflib('setFill',ncid,newMode);
