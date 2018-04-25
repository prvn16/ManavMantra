function putVar(ncid,varid,varargin)
%netcdf.putVar Write data to netCDF variable.
%   netcdf.putVar(ncid,varid,data) writes data to an entire netCDF
%   variable identified by varid and the file or group identified by ncid.
%
%   netcdf.putVar(ncid,varid,start,data) writes a single data value into 
%   the variable at the specified index. 
%
%   netcdf.putVar(ncid,varid,start,count,data) writes an array section 
%   of values into the netCDF variable.  The array section is specified 
%   by the start and count vectors, which give the starting index and 
%   count of values along each dimension of the specified variable.
%
%   netcdf.putVar(ncid,varid,start,count,stride,data) uses a sampling 
%   interval given by the stride argument.
%
%   This function corresponds to the "nc_put_var" family of functions in 
%   the netCDF library C API.
%
%   Example:  Write to the first ten elements of the example 'temperature'
%   variable.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.nc');
%       copyfile(srcFile,'myfile.nc');
%       fileattrib('myfile.nc','+w');
%       ncid = netcdf.open('myfile.nc','WRITE');
%       varid = netcdf.inqVarID(ncid,'temperature');
%       data = [100:109];
%       netcdf.putVar(ncid,varid,0,10,data);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.getVar.

%   Copyright 2008-2013 The MathWorks, Inc.

narginchk(3,6);
% Which family of functions?
switch nargin
  case 3
    funcstr = 'putVar';
  case 4
    funcstr = 'putVar1';
  case 5
    funcstr = 'putVara';
  case 6
    funcstr = 'putVars';
end


    


% Finalize the function string from the appropriate datatype.
validateattributes(varargin{end},{'numeric','char'},{},'','DATA');
switch ( class(varargin{end}) ) 
  case 'double' 
    funcstr = [funcstr 'Double']; 
  case 'single'
    funcstr = [funcstr 'Float']; 
  case 'int64' 
    funcstr = [funcstr 'Int64']; 
  case 'uint64' 
    funcstr = [funcstr 'Uint64']; 
  case 'int32' 
    funcstr = [funcstr 'Int']; 
  case 'uint32' 
    funcstr = [funcstr 'Uint']; 
  case 'int16' 
    funcstr = [funcstr 'Short']; 
  case 'uint16' 
    funcstr = [funcstr 'Ushort']; 
  case 'int8' 
    funcstr = [funcstr 'Schar']; 
  case 'uint8' 
    funcstr = [funcstr 'Uchar']; 
  case 'char' 
    funcstr = [funcstr 'Text']; 
end


% Invoke the correct netCDF library routine.
netcdflib(funcstr,ncid,varid,varargin{:});
