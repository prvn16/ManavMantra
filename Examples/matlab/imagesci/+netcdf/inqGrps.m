function childGrps = inqGrps(ncid)
%netcdf.inqGrps Return array of child group IDs.
%   childGrps = netcdf.inqGrps(ncid) returns all the child group IDs in 
%   a parent group.
%
%   This function corresponds to the "nc_inq_grps" function in the 
%   netCDF library C API.  
%
%   Example:
%       ncid = netcdf.open('example.nc','nowrite');
%       childGroups = netcdf.inqGrps(ncid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqNcid.

%   Copyright 2010-2013 The MathWorks, Inc.

childGrps = netcdflib('inqGrps',ncid);
