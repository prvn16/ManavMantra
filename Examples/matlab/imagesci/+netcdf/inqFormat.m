function fmt = inqFormat(ncid)
%netcdf.inqFormat Return format of netCDF file.
%   format = netcdf.inqFormat(ncid) returns the format version for the 
%   file specified by ncid.  format will be one of the following strings:
%
%       'FORMAT_CLASSIC' 
%       'FORMAT_64BIT' 
%       'FORMAT_NETCDF4' 
%       'FORMAT_NETCDF4_CLASSIC'
%
%   This function corresponds to the "nc_inq_format" function in the netCDF 
%   library C API.
%
%   Example:
%       ncid = netcdf.open('example.nc','NOWRITE');
%       fmt = netcdf.inqFormat(ncid);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.setDefaultFormat. 

%   Copyright 2010-2013 The MathWorks, Inc.

%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.

fmt = netcdflib('inqFormat',ncid);

