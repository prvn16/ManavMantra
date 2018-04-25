function data = getPixValues(gridID,rows,cols,fieldName)
%getPixValues Read data values for specified pixels.
%   DATA = getPixValues(gridID,ROWS,COLS,FIELDNAME) reads data values
%   for the pixels specified by the zero-based ROWS and COLS coordinates.
%   All entries along the non-geographic dimensions, i.e. NOT XDim and
%   YDim, are returned.
%
%   This function corresponds to the GDgetpixvalues function in the HDF-EOS
%   library C API.
%
%   Example:  Read the grid field's corner values.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       rows = [0 99 99  0];
%       cols = [0  0 99 99];
%       data = gd.getPixValues(gridID,rows,cols,'ice_temp');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.getPixels, gd.readField, gd.defBoxRegion, 
%   gd.extractRegion.

%   Copyright 2010-2013 The MathWorks, Inc.

[data,status] = hdf('GD','getpixvalues',gridID,cols,rows,fieldName);
hdfeos_gd_error(status,'GDgetpixvalues');

import matlab.io.hdfeos.*
dims = gd.fieldInfo(gridID,fieldName);
if numel(dims) > 2
    data = reshape(data,[dims(3:end) numel(rows)]);
end

    

