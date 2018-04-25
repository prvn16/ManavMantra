function origin = originInfo(gridID)
%originInfo  Retrieve the origin code.
%   ORIGINCODE = originInfo(gridID) retrieves the origin code for the
%   grid specified by gridID.  ORIGINCODE will be one of the four string 
%   values:
%
%       'ul' - upper-left
%       'ur' - upper-right
%       'll' - lower-left
%       'lr' - lower-right
%
%   This function corresponds to the GDorigininfo routine in the HDF-EOS 
%   library.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       origin = gd.originInfo(gridID);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defOrigin.

%   Copyright 2010-2013 The MathWorks, Inc.


try
    matlab.io.hdfeos.gd.gridInfo(gridID);
catch ALL
    error(message('MATLAB:imagesci:hdfeos:invalidGrid'));
end

origin = hdf('GD','origininfo',gridID);
if ~ischar(origin)
    hdfeos_gd_error(origin,'GDorigin');
end
