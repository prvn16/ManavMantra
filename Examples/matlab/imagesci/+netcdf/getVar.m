function data = getVar(ncid,varid,varargin)
%netcdf.getVar Return data from netCDF variable. 
%   data = netcdf.getVar(ncid,varid) reads an entire variable.  The 
%   class of the output data will match that of the netCDF variable.
%
%   data = netcdf.getVar(ncid,varid,start) reads a single value starting
%   at the specified index.
%
%   data = netcdf.getVar(ncid,varid,start,count) reads a contiguous
%   section of a variable.
%
%   data = netcdf.getVar(ncid,varid,start,count,stride) reads a strided
%   section of a variable.
% 
%   This function can be further modified by using a datatype string as 
%   the final input argument.  This has the effect of specifying the 
%   output datatype as long as the netCDF library allows the conversion.
%
%   The list of allowable datatype strings consists of 'double', 
%   'single', 'uint64', 'int64', 'uint32', 'int32', 'uint16', 'int16', 
%   'uint8', and 'uint8'.
%   
%   Example:  Read the entire example variable 'temperature' in as double
%   precision.
%       ncid = netcdf.open('example.nc','NOWRITE');
%       varid = netcdf.inqVarID(ncid,'temperature');
%       data = netcdf.getVar(ncid,varid,'double');
%       netcdf.close(ncid);
%
%   This function corresponds to the "nc_get_var" family of functions in 
%   the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.putVar.

%   Copyright 2008-2013 The MathWorks, Inc.

narginchk(2,6) ;

% How many index arguments do we have?  This tells us whether we
% are retrieving an entire variable, just a single value, a contiguous 
% subset, or a strided subset.
if (nargin > 2) && ischar(varargin{end})
    num_index_args = nargin - 2 - 1;
else
    num_index_args = nargin - 2;
end
    
% Figure out whether we are retrieving an entire variable, just a single
% value, a contiguous subset, or a strided subset.
switch ( num_index_args ) 
  case 0
    funcstr = 'getVar';  % retrieve the entire variable
  case 1
    funcstr = 'getVar1'; % retrieve just one element
  case 2
    funcstr = 'getVara'; % retrieve a contiguous subset
  case 3
    funcstr = 'getVars'; % retrieve a strided subset.
end


persistent nc_classes;
nc_classes = { 'double','float','single','int64','uint64', ...
               'int','int32','uint','uint32', 'short','int16', ...
               'ushort','uint16', 'schar','int8','uchar', ...
               'uint8','char','text'};
if (nargin > 2) && ischar(varargin{end})
    % An output datatype was specified.  Determine which funcstr
    % we need to use, and then don't forget to remove the output
    % datatype from the list of inputs.
    validatestring(varargin{end}, nc_classes);
    switch ( varargin{end} )
      case 'double'
        funcstr = [funcstr 'Double'];
      case { 'float', 'single' }
        funcstr = [funcstr 'Float'];
      case { 'int64' }
        funcstr = [funcstr 'Int64'];
      case { 'uint64' }
        funcstr = [funcstr 'Uint64'];
      case { 'int', 'int32' }
        funcstr = [funcstr 'Int'];
      case { 'uint', 'uint32' }
        funcstr = [funcstr 'Uint'];
      case { 'short', 'int16' }
        funcstr = [funcstr 'Short'];
      case { 'ushort', 'uint16' }
        funcstr = [funcstr 'Ushort'];
      case { 'schar', 'int8' }
        funcstr = [funcstr 'Schar'];
      case { 'uchar', 'uint8' }
        funcstr = [funcstr 'Uchar'];
      case { 'text', 'char' }
        funcstr = [funcstr 'Text'];
    end
    
    data = netcdflib(funcstr,ncid,varid,varargin{1:end-1});            
    
else
    % The last argument is not character, meaning we keep the 
    % native datatype.
    [~,xtype] = netcdf.inqVar(ncid,varid);
    switch(xtype)
      case 11 % NC_UINT64
        funcstr = [funcstr 'Uint64'];
      case 10 % NC_INT64
        funcstr = [funcstr 'Int64'];
      case 9 % NC_UINT
        funcstr = [funcstr 'Uint'];
      case 8 % NC_USHORT
        funcstr = [funcstr 'Ushort'];
      case 7 % NC_UBYTE
        funcstr = [funcstr 'Uchar'];
      case 6 % NC_DOUBLE
        funcstr = [funcstr 'Double'];
      case 5 % NC_FLOAT
        funcstr = [funcstr 'Float'];
      case 4 % NC_INT
        funcstr = [funcstr 'Int'];
      case 3 % NC_SHORT
        funcstr = [funcstr 'Short'];
      case 2 % NC_CHAR
        funcstr = [funcstr 'Text'];
      case 1 
        % NC_BYTE.  This is an unusual case.  The netCDF datatype
        % is ambiguous here as to whether it is uint8 or int8.  
        % We will assume int8.
        funcstr = [funcstr 'Schar'];
      otherwise
        error(message('MATLAB:imagesci:netcdf:unrecognizedVarDatatype', xtype));
    end
    
    data = netcdflib(funcstr,ncid,varid,varargin{:});            

end

    
