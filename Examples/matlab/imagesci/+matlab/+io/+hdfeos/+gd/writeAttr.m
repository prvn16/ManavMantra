function writeAttr(gridID,attrName,data)
%writeAttr Write grid attribute.
%   writeAttr(gridID,ATTRNAME,DATA) writes an attribute to a grid.  If
%   the attribute does not exist, it is created.  If the attribute exists,
%   it may be modified in place, but it may not recreated with a different 
%   datatype or length.
%
%   This function corresponds to the GDwriteattr function in the HDF-EOS
%   library C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','imagesci','grid.hdf');
%       copyfile(srcFile,'myfile.hdf');
%       fileattrib('myfile.hdf','+w');
%       gfid = gd.open('myfile.hdf','rdwr');
%       gridID = gd.attach(gfid,'PolarGrid');
%       gd.writeAttr(gridID,'modification_date',datestr(now));
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.readAttr.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('GD','writeattr',gridID,attrName,data);
hdfeos_gd_error(status,'GDwriteattr');
