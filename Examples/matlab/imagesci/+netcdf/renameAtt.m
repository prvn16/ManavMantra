function renameAtt(ncid,varid,oldname,newname)
%netcdf.renameAtt Change name of netCDF attribute.
%   netcdf.renameAtt(ncid,varid,oldName,newName) renames the attribute 
%   identified by oldName to newName.  The attribute is associated with
%   the variable identified by varid.  A global attribute can be 
%   specified by using netcdf.getConstant('GLOBAL') for the varid.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide".  This function 
%   corresponds to the "nc_rename_att" function in the netCDF library C 
%   API.
% 
%   Example:  Rename the global attribute 'creation_date' to
%   'modification_date'.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.nc');
%       copyfile(srcFile,'myfile.nc');
%       fileattrib('myfile.nc','+w');
%       ncid = netcdf.open('myfile.nc','WRITE');
%       varid = netcdf.getConstant('GLOBAL');
%       netcdf.renameAtt(ncid,varid,'creation_date','modification_date');
%       netcdf.close(ncid);
% 
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.renameDim, netcdf.renameVar.


%   Copyright 2008-2013 The MathWorks, Inc.

netcdflib('renameAtt', ncid, varid, oldname, newname );
