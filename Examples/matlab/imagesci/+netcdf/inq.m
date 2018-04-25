function [ndims,nvars,ngatts,unlimdimid] = inq(ncid)
%netcdf.inq Return information about netCDF file.
%   [ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid) inquires as to 
%   the number of dimensions, number of variables, number of global 
%   attributes, and the identity of the unlimited dimension, if any,
%   in the file or group specified by ncid.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide".  This function 
%   corresponds to the "nc_inq" function in the netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NC_NOWRITE');
%       [numdims,numvars,numglobalatts,unlimdimid] = netcdf.inq(ncid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqDimIDs, netcdf.inqVarIDs.

%   Copyright 2008-2013 The MathWorks, Inc.

[ndims,nvars,ngatts,unlimdimid] = netcdflib('inq',ncid);
