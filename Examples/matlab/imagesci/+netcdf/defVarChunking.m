function defVarChunking(ncid,varid,storage,chunkdims)
%netcdf.defVarChunking Define chunk settings for netCDF variable.
%   netcdf.defVarChunking(ncid,varid,storage,chunkDims) sets the chunk 
%   settings to the type specified by storage and the chunk extents to 
%   that specified by chunkDims.  storage may be either 'CHUNKED' or 
%   'CONTIGUOUS'.  This operation may not be used on netCDF-3 files.
% 
%   chunkDims may be omitted if storage is 'CONTIGUOUS'.
%
%   Example:  Create a variable with dimensions [1800 3600] and a chunked 
%   layout that is a 10x10 grid.
%       ncid = netcdf.create('myfile.nc','NETCDF4');
%       latdimid = netcdf.defDim(ncid,'lat',1800);
%       londimid = netcdf.defDim(ncid,'col',3600);
%       varid = netcdf.defVar(ncid,'earthgrid','double',[latdimid londimid]);
%       netcdf.defVarChunking(ncid,varid,'CHUNKED',[180 360]);
%       netcdf.close(ncid);
%
%   This function corresponds to the "nc_def_var_chunking" function in the
%   netCDF library C API.  Because MATLAB uses FORTRAN-style ordering,
%   however, the order of the chunkdims is reversed relative to what would
%   be in the C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqVarChunking.
%

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(storage)
    storage = netcdf.getConstant(storage);
end

if nargin < 4
	chunkdims = [];
end

netcdflib('defVarChunking',ncid,varid,storage,chunkdims);            
