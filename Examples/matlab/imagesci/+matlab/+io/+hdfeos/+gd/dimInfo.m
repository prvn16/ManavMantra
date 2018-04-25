function dimlen = dimInfo(gridID,dimname)
%dimInfo Retrieve length of dimension.
%   DIMLEN = diminfo(gridID,DIMNAME) retrieves the length of the
%   specified user-defined dimension.  
%
%   Please note that the two extents used to create the grid are not 
%   considered user-defined dimensions.  To retrieve the length of XDim and
%   YDim, use gd.gridInfo.
%    
%   This function corresponds to the GDdiminfo function in the HDF-EOS
%   library C API.
%
%   Example:  Inquire about a 'Bands' dimension.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       dimlen = gd.dimInfo(gridID,'Height');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defDim, gd.gridInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

dimlen = hdf('GD','diminfo',gridID,dimname);
hdfeos_gd_error(dimlen,'GDdiminfo');
