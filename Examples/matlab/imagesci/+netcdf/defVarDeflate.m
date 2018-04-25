function defVarDeflate(ncid,varid,shuffle,deflate,deflateLevel)
%netcdf.defVarDeflate Define compression parameters for netCDF variable.
%   netcdf.defVarDeflate(ncid,varid,shuffle,deflate,deflateLevel) sets the 
%   compression parameters for a netCDF variable specified by varid in the 
%   location specified by ncid.
%
%   If shuffle is true, the shuffle filter is turned on.
%
%   If deflate is true, the deflate filter is turned on and set to the 
%   deflateLevel, which must be between 0 and 9.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide".  This function 
%   corresponds to the "nc_def_var_deflate" function in the netCDF library 
%   C API.  
%
%   Example:  Create a variable with dimensions [1800 3600] and a deflate 
%   compression level of 5 on a chunked layout that is a 100x200 grid.
%       ncid = netcdf.create('myfile.nc','NETCDF4');
%       latdimid = netcdf.defDim(ncid,'lat',1800);
%       londimid = netcdf.defDim(ncid,'col',3600);
%       varid = netcdf.defVar(ncid,'earthgrid','double',[latdimid londimid]);
%       netcdf.defVarChunking(ncid,varid,'CHUNKED',[100 200]);
%       netcdf.defVarDeflate(ncid,varid,true,true,5);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqVarDeflate.

%   Copyright 2010-2013 The MathWorks, Inc.

netcdflib('defVarDeflate',ncid,varid,shuffle,deflate,deflateLevel);
