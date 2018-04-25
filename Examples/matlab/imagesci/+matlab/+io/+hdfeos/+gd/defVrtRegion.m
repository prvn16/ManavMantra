function regionID2 = defVrtRegion(gridID,regionID,vobj,vrange)
%defVrtRegion Define vertical subset region.
%   OUT_RID = defVrtRegion(gridID,REGIONID,VOBJ,VRANGE) defines a 
%   vertical subset region and may be used on either a monotonic field or
%   contiguous elements of a dimension.
%
%   REGIONID should be 'noprevsub' if no prior subsetting has occurred. 
%   Otherwise it should be a value as returned from a previous subsetting 
%   routine.
%
%   VOBJ is the name of either the dimension or field to subset.  If VOBJ 
%   is a dimension, it should be prefixed with 'DIM:'.
%
%   VRANGE is the minimum and maximum range for the vertical subset.
% 
%   This function corresponds to the GDdefvrtregion function in the HDF-EOS
%   library C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       range = [333 667];
%       regionID = gd.defVrtRegion(gridID,'noprevsub','Height',range);
%       data = gd.extractRegion(gridID,regionID,'pressure');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       range = [3 5];
%       regionID = gd.defVrtRegion(gridID,'noprevsub','DIM:Height',range);
%       data = gd.extractRegion(gridID,regionID,'pressure');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.extractRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(regionID) && strcmp(regionID,'noprevsub')
    regionID = -1;
end
regionID2 = hdf('GD','defvrtregion',gridID,regionID,vobj,vrange);
hdfeos_gd_error(regionID2,'GDdefvrtregion');
