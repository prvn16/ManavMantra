function pixReg = pixRegInfo(gridID)
%pixRegInfo  Retrieve the pixel registration code.
%   PIXREGCODE = pixRegInfo(gridID) retrieve the pixel registration code
%   for the grid identified by gridID.  PIXREGCODE can be one of the
%   following strings:
%
%       'center' - center of pixel cell
%       'corner' - corner of pixel cell
%
%   This function corresponds to the GDpixreginfo routine in the HDF-EOS 
%   library.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       code = gd.pixRegInfo(gridID);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defPixReg.

%   Copyright 2010-2013 The MathWorks, Inc.

try
    matlab.io.hdfeos.gd.gridInfo(gridID);
catch ALL
    error(message('MATLAB:imagesci:hdfeos:invalidGrid'));
end

pixReg = hdf('GD','pixreginfo',gridID);
if ~ischar(pixReg)
    hdfeos_gd_error(pixReg,'GDpixreginfo');
end
