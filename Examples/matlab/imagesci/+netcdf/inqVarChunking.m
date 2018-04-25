function [storage,chunkDims] = inqVarChunking(ncid,varid)
%netcdf.inqVarChunking Return chunking settings for netCDF variable.
%   [storage,chunkSizes] = netcdf.inqVarChunking(ncid,varid) returns the 
%   chunk type and the array of chunksizes of a netCDF variable in the file
%   or group specified by ncid.  storage will be either 'CHUNKED', or 
%   'CONTIGUOUS'.
%
%   This function corresponds to the "nc_inq_var_chunking" function in the
%   netCDF library C API.  Because MATLAB uses FORTRAN-style ordering,
%   however, the order of the chunking extents is reversed relative to what
%   would be obtained from the C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       groupid = netcdf.inqNcid(ncid,'grid1');
%       varid = netcdf.inqVarID(groupid,'temp');
%       [storage,chunkSize] = netcdf.inqVarChunking(groupid,varid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.defVar, netcdf.defVarChunking.

%   Copyright 2010-2013 The MathWorks, Inc.

[storage,chunkDims] = netcdflib('inqVarChunking',ncid,varid);            
