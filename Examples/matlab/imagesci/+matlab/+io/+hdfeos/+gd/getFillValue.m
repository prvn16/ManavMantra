function fillvalue = getFillValue(gridID,fieldname)
%getFillValue  Retrieve fill value for specified field.
%   FILLVALUE = getFillValue(GRIDID,FIELDNAME) retrieves the fill value
%   for the specified field.
%
%   This function corresponds to the GDgetfillvalue function in the HDF-EOS
%   library C API.
%
%   Example:  Return the fill value for the 'ice_temp' field in the
%   'PolarGrid' grid.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       fillvalue = gd.getFillValue(gridID,'ice_temp');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.setFillValue.

%   Copyright 2010-2013 The MathWorks, Inc.

[fillvalue,status] = hdf('GD','getfillvalue',gridID,fieldname);
hdfeos_gd_error(status,'GDgetfillvalue');
