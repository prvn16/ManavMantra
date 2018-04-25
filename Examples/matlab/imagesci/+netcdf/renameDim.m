function renameDim(ncid,dimid,new_name)
%netcdf.renameDim Change name of netCDF dimension.
%   netcdf.renameDim(ncid,dimid,newName) renames a dimension identified
%   by dimid to the new name.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide".  This function 
%   corresponds to the "nc_rename_dim" function in the netCDF library C 
%   API.
%
%   Example:
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.nc');
%       copyfile(srcFile,'myfile.nc');
%       fileattrib('myfile.nc','+w');
%       ncid = netcdf.open('myfile.nc','WRITE');
%       netcdf.reDef(ncid);
%       dimid = netcdf.inqDimID(ncid,'x');
%       netcdf.renameDim(ncid,dimid,'new_x');
%       netcdf.close(ncid);
%       
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.reDef, netcdf.renameVar.
%

%   Copyright 2008-2013 The MathWorks, Inc.

netcdflib('renameDim', ncid, dimid, new_name);            
