function detach(gridID)
%detach Detach from existing grid.
%   detach(gridID) detaches from the grid identified by gridID.
%
%   This function corresponds to the GDdetach function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfID = gd.open('grid.hdf');
%       gridID = gd.attach(gfID,'PolarGrid');
%       gd.detach(gridID);
%       gd.close(gfID);
%
%    See also gd, gd.attach.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('GD','detach',gridID);
hdfeos_gd_error(status,'GDdetach');
