function dimid = defDim(ncid,dimname,dimlen)
%netcdf.defDim Create netCDF dimension.
%   dimid = netcdf.defDim(ncid,dimname,dimlen) creates a new dimension 
%   given its name and length.  The return value is the numeric ID
%   corresponding to the new dimension.  dimlen for unlimited dimensions
%   should be specified by the constant value for 'UNLIMITED'.
%
%   This function corresponds to the "nc_def_dim" function in the netCDF 
%   library C API.
%
%   Example:  Create a netCDF file with a fixed-size dimension called 'lat'
%   and an unlimited dimension called 'time'.
%       ncid      = netcdf.create('myfile.nc','NOCLOBBER');
%       latDimId  = netcdf.defDim(ncid,'latitude',180);
%       timeDimId = netcdf.defDim(ncid,'time',netcdf.getConstant('UNLIMITED'));
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVar, netcdf.inqDimIDs.

%   Copyright 2008-2013 The MathWorks, Inc.

dimid = netcdflib('defDim', ncid,dimname,dimlen);            
