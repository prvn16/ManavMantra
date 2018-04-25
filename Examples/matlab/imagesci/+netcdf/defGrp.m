function childNcid = defGrp(ncid,childGroupName)
%netcdf.defGrp Create group.
%   childGrpID = netcdf.defGrp(parentGroupId,childGroupName) creates a child 
%   group with name childGroupName given the identifier of the parent 
%   group specified by parentGroupId.
%
%   This function corresponds to the "nc_def_grp" function in the netCDF 
%   library C API.  
%
%   Example:
%       ncid = netcdf.create('myfile.nc','netcdf4');
%       childGroupId = netcdf.defGrp(ncid,'mygroup');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqGrps.

%   Copyright 2010-2013 The MathWorks, Inc.

childNcid = netcdflib('defGrp',ncid,childGroupName);
