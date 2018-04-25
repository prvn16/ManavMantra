function varid = defVar(ncid,varname,xtype,dimids)
%netcdf.defVar Create netCDF variable.
%   varid = netcdf.defVar(ncid,varname,xtype,dimids) creates a new 
%   variable given a name, datatype, and list of dimension IDs.  The 
%   datatype is given by xtype, and can be either a string 
%   representation such as 'double', or it may be the numeric equivalent
%   provided by netcdf.getConstant.  The return value is the numeric ID 
%   corresponding to the new variable.
%
%   This function corresponds to the "nc_def_var" function in the netCDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   the fastest-varying dimension comes first and the slowest comes 
%   last.  Any unlimited dimension is therefore last in the list of 
%   dimension IDs.  This ordering is the reverse of that found in the C 
%   API.
%
%   Example:  Create a coordinate variable called 'latitude'.  A coordinate
%   variable is a variable that has exactly one dimension with the same
%   name.
%       ncid = netcdf.create('myfile.nc','CLOBBER');
%       dimid =  netcdf.defDim(ncid,'latitude',180);
%       varid = netcdf.defVar(ncid,'latitude','double',dimid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVar netcdf.getConstant.
%

%   Copyright 2008-2013 The MathWorks, Inc.

if ischar(xtype)
    xtype = netcdf.getConstant(xtype);
end

varid = netcdflib('defVar', ncid, varname, xtype, dimids);            
