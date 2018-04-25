function [dimname,dimlen] = inqDim(ncid,dimid)
%netcdf.inqDim Return netCDF dimension name and length.
%   [dimname, dimlen] = netcdf.inqDim(ncid,dimid) returns the name and 
%   length of a dimension given the dimension identifier.
%
%   To use this function, you should be familiar with the information about 
%   netCDF contained in the "NetCDF C Interface Guide".  This function 
%   corresponds to the "nc_inq_dim" function in the netCDF library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       dimid = netcdf.inqDimID(ncid,'x');
%       [~,length] = netcdf.inqDim(ncid,dimid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.inqDimID, netcdf.inqVar.
    
%   Copyright 2008-2013 The MathWorks, Inc.

[dimname,dimlen] = netcdflib('inqDim', ncid,dimid);            
