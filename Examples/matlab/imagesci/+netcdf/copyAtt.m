function copyAtt(ncid_in,varid_in,attname,ncid_out,varid_out)
%netcdf.copyAtt Copy attribute to new location.
%   netcdf.copyAtt(ncid_in,varid_in,attname,ncid_out,varid_out) copies 
%   an attribute from one variable to another, possibly across files.
%
%   This function corresponds to the "nc_copy_att" function in the netCDF 
%   library C API.
%
%   Example:
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.nc');
%       copyfile(srcFile,'myfile.nc');
%       fileattrib('myfile.nc','+w');
%       ncid = netcdf.open('myfile.nc','WRITE');
%       varid_in = netcdf.inqVarID(ncid,'temperature');
%       varid_out = netcdf.inqVarID(ncid,'peaks');
%       netcdf.copyAtt(ncid,varid_in,'scale_factor',ncid,varid_out);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.putAtt.

%   Copyright 2008-2013 The MathWorks, Inc.

netcdflib('copyAtt', ncid_in, varid_in, attname, ncid_out, varid_out);
