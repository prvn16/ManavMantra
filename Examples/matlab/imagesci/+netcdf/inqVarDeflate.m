function [shuffle,deflate,deflateLevel] = inqVarDeflate(ncid,varid)
%netcdf.inqVarDeflate Return compression settings for netCDF variable.
%   [shuffle,deflate,deflateLevel] = netcdf.inqVarDeflate(ncid,varid) 
%   returns the shuffle flag and deflate setting of a variable 
%   identified by varid in the file or group identified by ncid.
%
%   If shuffle is true, then the shuffle filter was turned on.
%
%   If deflate is true, then the deflate filter was turned on and the 
%   deflate level is returned in deflateLevel.
%
%   This function corresponds to the "nc_inq_var_deflate" function in the
%   netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       groupid = netcdf.inqNcid(ncid,'grid1');
%       varid = netcdf.inqVarID(groupid,'temp');
%       [shuffle,deflate,deflateLevel] = netcdf.inqVarDeflate(groupid,varid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVarDeflate.

%   Copyright 2010-2013 The MathWorks, Inc.

[shuffle,deflate,deflateLevel] = netcdflib('inqVarDeflate',ncid,varid);            
