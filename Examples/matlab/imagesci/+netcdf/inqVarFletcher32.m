function setting = inqVarFletcher32(ncid,varid)
%netcdf.inqVarFletcher32 Return fletcher32 setting for netCDF variable.
%   setting = netcdf.inqVarFletcher32(ncid,varid) returns the checksum 
%   setting for a netCDF variable specified by varid and the file 
%   or group specified by ncid.  setting will be one of the following 
%   strings:
%
%       'NOCHECKSUM' - fletcher32 checksum filter not turned on
%       'FLETCHER32' - fletcher32 checksum filter turned on
%
%   This function corresponds to the "nc_inq_var_fletcher32" function in
%   the netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       varid = netcdf.inqVarID(ncid,'temperature');
%       setting = netcdf.inqVarFletcher32(ncid,varid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVarFletcher32.

%   Copyright 2010-2013 The MathWorks, Inc.

setting = netcdflib('inqVarFletcher32',ncid,varid);            
