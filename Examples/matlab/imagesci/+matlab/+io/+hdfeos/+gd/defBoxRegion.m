function regionID = defBoxRegion(gridID,cornerLat,cornerLon)
%defBoxRegion Define region of interest by latitude and longitude.
%   REGIONID = defBoxRegion(gridIDID,CORNERLAT,CORNERLON) defines a 
%   latitude-longitude box region as a subset region for a grid.  REGIONID
%   may be used to read all the entries of a data field within the region.
%   
%   This function corresponds to the GDdefboxregion function in the HDF-EOS
%   library C API.
%
%   Example:  Define a region of interest between 20 and 50 degrees
%   latitude and between -90 and -60 degrees longitude.
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
%   See also gd, gd.extractRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

regionID = hdf('GD','defboxregion',gridID,cornerLon,cornerLat);
hdfeos_gd_error(regionID,'GDdefboxregion');
