function [xtype,attlen] = inqAtt(ncid,varid,attname)
%netcdf.inqAtt Return information about netCDF attribute.
%   [xtype,attlen] = netcdf.inqAtt(ncid,varid,attname) returns
%   the datatype and length of an attribute identified by attname.
%
%   This function corresponds to the "nc_inq_att" function in the netCDF 
%   library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       varid = netcdf.inqVarID(ncid,'temperature');
%       [xtype,attlen] = netcdf.inqAtt(ncid,varid,'scale_factor');
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.getAtt, netcdf.putAtt.

%   Copyright 2008-2013 The MathWorks, Inc.

[xtype,attlen] = netcdflib('inqAtt', ncid, varid,attname);            
