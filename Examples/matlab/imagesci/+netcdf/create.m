function varargout = create(filename, mode, varargin)
%netcdf.create Create new netCDF file.
%   ncid = netcdf.create(filename, mode) creates a new netCDF file 
%   according to the file creation mode.  The return value is a file
%   ID.  
%   
%   The type of access is described by the mode parameter, which could
%   be one of the following string values or a bitwise-or of numeric mode
%   values:
%
%       'CLOBBER'       - overwrite existing files
%       'NOCLOBBER'     - do not overwrite existing files
%       'SHARE'         - allow for synchronous file updates
%       '64BIT_OFFSET'  - allow the creation of 64-bit files instead of
%                         the classic format
%       'NETCDF4'       - create a netCDF-4/HDF5 file
%       'CLASSIC_MODEL' - enforce classic model, has no effect unless used
%                         in a bitwise-or with 'NETCDF4'
%
%   [chunksize_out, ncid]=netcdf.create(filename,mode,initsz,chunksize) 
%   creates a new netCDF file with additional performance tuning 
%   parameters.  initsz sets the initial size of the file.  
%   chunksize can affect I/O performance.  The actual value chosen by 
%   the netCDF library may not correspond to the input value.
%
%   This function corresponds to the "nc_create" and "nc__create" functions 
%   in the netCDF library C API.
%
%   Example:  create a netCDF file that overwrites any existing file by the
%   same name.
%       ncid = netcdf.create('myfile.nc','CLOBBER');
%       netcdf.close(ncid);
%
%   Example:  create a netCDF-4 file that uses the classic model.
%       mode = netcdf.getConstant('NETCDF4');
%       mode = bitor(mode,netcdf.getConstant('CLASSIC_MODEL'));
%       ncid = netcdf.create('myfile.nc',mode);
%       netcdf.close(ncid);
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.getConstant, BITOR.
%

%   Copyright 2008-2013 The MathWorks, Inc.

validateattributes(mode,{'char','numeric'},{'row'},'netcdf.create','mode');

varargout = cell(1,nargout);
switch nargin
    case 2
        ncid = netcdflib('create', filename, mode);
        varargout{1} = ncid;
    case 4
        [czout,ncid] = netcdflib('pCreate', filename, mode, varargin{:});
        varargout{1} = czout;
        varargout{2} = ncid;
    otherwise
        error (message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end




