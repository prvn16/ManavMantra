function renameVar(ncid,varid,new_name)
%netcdf.renameVar Change name of netCDF variable.
%   netcdf.renameVar(ncid,varid,newName) renames the variable identified 
%   by varid in the netCDF file or group associated with ncid.
%
%   This function corresponds to the "nc_rename_var" function in the netCDF
%   library C API.
%
%   Example:
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.nc');
%       copyfile(srcFile,'myfile.nc');
%       fileattrib('myfile.nc','+w');
%       ncid = netcdf.open('myfile.nc','WRITE');
%       varid = netcdf.inqVarID(ncid,'temperature');
%       netcdf.renameVar(ncid,varid,'fahrenheight_temperature');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.renameDim, netcdf.renameAtt.

%   Copyright 2008-2013 The MathWorks, Inc.

netcdflib('renameVar', ncid, varid, new_name);            
