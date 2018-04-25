function data = extractRegion(gridID,regionID,fieldName)
%extractRegion Read region of interest from field.
%   DATA = extractRegion(gridID,REGIONID,FIELDNAME) extract data from a
%   subsetted region.
%   
%   This routine corresponds to the GDextractregion function in the HDF-EOS
%   library C API.
%
%   Example:  Define and extract a region of interest between 20 and 50
%   degrees latitude and between -90 and -60 degrees longitude.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       cornerlat = [20 50];
%       cornerlon = [-90 -60];
%       regionID = gd.defBoxRegion(gridID,cornerlat,cornerlon);
%       data = gd.extractRegion(gridID,regionID,'ice_temp');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defBoxRegion, gd.defVrtRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

[data,status] = hdf('GD','extractregion',gridID,regionID,fieldName);
hdfeos_gd_error(status,'GDextractgion');
