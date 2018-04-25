function libvers = inqLibVers()
%netcdf.inqLibVers Return netCDF library version information.
%   libvers = netcdf.inqLibVers returns a string identifying the 
%   version of the netCDF library.
%
%   This function corresponds to the "nc_inq_libvers" function in the 
%   netCDF library C API.
%
%   Example:
%       libvers = netcdf.inqLibVers();
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%  
%   See also netcdf.

%   Copyright 2008-2015 The MathWorks, Inc.

libvers = netcdflib('inqLibVers');

% The version sring returned from the netCDF library contains the version
% plus extra date information, so we need remove everything after
% the version.  
% With netCDF official release 4.3.3.1, need to extract two extra
% characters due to the ".1".
libvers = libvers(1:7);
