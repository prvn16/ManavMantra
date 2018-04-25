function [varname,xtype,dimids,natts] = inqVar(ncid,varid)
%netcdf.inqVar Return information about netCDF variable.
%   [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid) returns
%   the name, datatype, dimensions IDs, and the number of attributes of 
%   the variable identified by varid.
%
%   This function corresponds to the "nc_inq_var" function in the netCDF
%   library C API. Because MATLAB uses FORTRAN-style ordering, however, the
%   order of the dimension IDs is reversed relative to what would be
%   obtained from the C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       varid = netcdf.inqVarID(ncid,'temperature');
%       [name,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVar.
%

%   Copyright 2008-2013 The MathWorks, Inc.

[varname,xtype,dimids,natts] = netcdflib('inqVar', ncid, varid);            
