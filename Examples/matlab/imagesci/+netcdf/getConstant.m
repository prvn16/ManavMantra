function param = getConstant(param_name)
%netcdf.getConstant Return numeric value of named constant.
%   val = netcdf.getConstant(param_name) returns the numeric value 
%   corresponding to the name of a constant defined by the netCDF
%   library.  
%
%   The value for param_name can be either upper case or lower case, and
%   does not need to include the leading three characters 'NC_'.
%
%   The list of all names can be retrieved with netcdf.getConstantNames
%
%   Example:
%       val = netcdf.getConstant('NOCLOBBER');
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.getConstantNames
%

%   Copyright 2008-2013 The MathWorks, Inc.

param = netcdflib('parameter', param_name);            
