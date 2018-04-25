function endDef(ncid,varargin)
%netcdf.endDef End netCDF file define mode.
%   netcdf.endDef(ncid) Takes a netCDF file identified by ncid out of
%   define mode.
%
%   netcdf.endDef(ncid,h_minfree,v_align,v_minfree,r_align) is the same as
%   netcdf.endDef, but with the addition of four performance tuning
%   parameters.  One reason for using the performance parameters is to
%   reserve extra space in the netCDF file header using the h_minfree
%   parameter.
%
%   Example:  Reserve 20000 bytes in the netCDF header which may be used
%   at a later time when adding attributes.  This can be extremely
%   efficient when working with very large netCDF-3 files.
%       ncid = netcdf.create('myfile.nc','CLOBBER');
%       % define dimensions, variables
%       netcdf.endDef(ncid,20000,4,0,4);
%       netcdf.close(ncid);
%
%   This function corresponds to the "nc_enddef" and "nc__enddef" functions 
%   in the netCDF library C API.
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%
%   See also netcdf, netcdf.create, netcdf.reDef.

%   Copyright 2008-2013 The MathWorks, Inc.


switch nargin
    case 1
        netcdflib('endDef', ncid);
    case 5
        netcdflib('pEndDef', ncid, varargin{:});
    otherwise
        error (message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end

