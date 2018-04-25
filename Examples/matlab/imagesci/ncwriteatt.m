function ncwriteatt(ncFile, location, attName, attValue)
%NCWRITEATT Write attribute to NetCDF file.
%
%    NCWRITEATT(FILENAME, LOCATION, ATTNAME, ATTVALUE) create or modify
%    an attribute ATTNAME in the group or variable specified by LOCATION.
%    To specify global attributes, set LOCATION to '/'. ATTVALUE can be a
%    numeric vector or a string.
%
%
%    Example: Create a global attribute.
%      copyfile(which('example.nc'),'myfile.nc');
%      fileattrib('myfile.nc','+w');
%      ncdisp('myfile.nc');
%      ncwriteatt('myfile.nc','/','modification_date',datestr(now));
%      ncdisp('myfile.nc');
%
%    Example: Modify an existing variable attribute.
%      copyfile(which('example.nc'),'myfile.nc');
%      fileattrib('myfile.nc','+w');
%      ncdisp('myfile.nc','peaks');
%      ncwriteatt('myfile.nc','peaks','description','Output of PEAKS');
%      ncdisp('myfile.nc','peaks');
%
%    See also ncdisp, ncreadatt, ncwrite, ncread, nccreate, netcdf.

%   Copyright 2010-2013 The MathWorks, Inc.

if(~exist(ncFile,'file'))
    %error out if file does not exist.
    error(message('MATLAB:imagesci:netcdf:fileDoesNotExist', ncFile));
end

ncObj   = internal.matlab.imagesci.nc(ncFile,'a');
cleanUp = onCleanup(@()ncObj.close());

ncObj.writeAttribute(location, attName, attValue);
