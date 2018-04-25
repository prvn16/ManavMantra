function attValue = ncreadatt(ncFile, location, attName)
%NCREADATT Read attribute value from a NetCDF source.
%
%    ATTVALUE = NCREADATT(FILENAME, LOCATION, ATTNAME) reads the
%    attribute ATTNAME from the group or variable specified by the string
%    LOCATION. To read global attributes set LOCATION to '/'.
%
%    ATTVALUE = NCREADATT(OPENDAP_URL, LOCATION, ATTNAME) reads from an
%    OPeNDAP NetCDF data source.
%
%    Example: Read a global attribute.
%      creation_date = ncreadatt('example.nc','/','creation_date');
%      disp(creation_date);
%
%    Example: Read a variable attribute.
%      scale_factor = ncreadatt('example.nc','temperature','scale_factor');
%      disp(scale_factor);
%
%
%    See also ncread, ncinfo, ncdisp, ncwriteatt, netcdf.

%   Copyright 2010-2013 The MathWorks, Inc.

ncObj    = internal.matlab.imagesci.nc(ncFile);
cleanUp  = onCleanup(@()ncObj.close());

attValue = ncObj.readAttribute(location, attName);
