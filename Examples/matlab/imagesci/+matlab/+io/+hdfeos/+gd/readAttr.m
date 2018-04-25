function data = readAttr(gridID,attrName)
%readAttr Read grid attribute.
%   data = readAttr(GRIDID,ATTRNAME) reads a grid attribute.
%
%   This function corresponds to the GDreadattr function in the HDF-EOS
%   library C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       data = gd.readAttr(gridID,'creation_date');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.writeAttr.

%   Copyright 2010-2015 The MathWorks, Inc.

[data,status] = hdf('GD','readattr',gridID,attrName);
hdfeos_gd_error(status,'GDreadattr');
