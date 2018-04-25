function defVarFletcher32(ncid,varid,setting)
%netcdf.defVarFletcher32 Define checksum parameters for netCDF variable.
%   netcdf.defVarFletcher32(ncid,varid,setting) defines the checksum settings 
%   for a netCDF variable specified by varid in the file specified by 
%   ncid.
%
%   The setting can be either 'NOCHECKSUM' or 'FLETCHER32'.  If setting is 
%   'fletcher32', then checksums will be turned on for this variable.
%
%   This function corresponds to the "nc_def_var_fletcher32" function in 
%   the netCDF library C API.  
%
%   Example:
%       ncid = netcdf.create('myfile.nc','NETCDF4');
%       latdimid = netcdf.defDim(ncid,'lat',1800);
%       londimid = netcdf.defDim(ncid,'col',3600);
%       varid = netcdf.defVar(ncid,'earthgrid','double',[latdimid londimid]);
%       netcdf.defVarFletcher32(ncid,varid,'FLETCHER32');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqVarFletcher32.

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(setting)
	setting = netcdf.getConstant(setting);
end
netcdflib('defVarFletcher32',ncid,varid,setting);            
