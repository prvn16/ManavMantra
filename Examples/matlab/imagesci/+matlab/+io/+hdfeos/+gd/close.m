function close(gfid)
%close Close HDF-EOS grid file.
%   close(gfID) closes an HDF-EOS grid file identified by gfID.
%
%   This function corresponds to the GDclose function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfID = gd.open('grid.hdf');
%       gd.close(gfID);
%
%   See also gd, gd.open, gd.create.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('GD','close',gfid);
hdfeos_gd_error(status,'GDclose');
