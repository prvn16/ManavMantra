function [dims,upleft,lowright] = regionInfo(gridID,regionID,fieldName)
%regionInfo Return information about subsetted region.
%   [DIMS,UPLEFT,LOWRIGHT] = regionInfo(gridID,regionID,FIELDNAME)
%   returns the dimensions and corner points for the specified field of a
%   subsetted region identified by regionID in the grid identified by
%   gridID.
%
%   This function corresponds to the GDregioninfo function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       cornerlat = [20 50];
%       cornerlon = [-90 -60];
%       regionID = gd.defBoxRegion(gridID,cornerlat,cornerlon);
%       [dims,upleft,lowright] = gd.regionInfo(gridID,regionID,'ice_temp');
%       data = gd.extractRegion(gridID,regionID,'ice_temp');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defBoxRegion, gd.defVrtRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

[~,~,dims,~,upleft,lowright,status] = hdf('GD','regioninfo',gridID,regionID,fieldName);
hdfeos_gd_error(status,'GDregioninfo');

% Remember, must flip the dimensions to account for row/col-major order
% differences.
dims = fliplr(dims);
