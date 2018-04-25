function setFillValue(gridID,fieldName,fillValue)
%setFillValue Set the fill value for the specified field.
%   setFillValue(gridID,FIELDNAME,FILLVALUE) sets the fill value for the
%   specified field.  The fill value should have the same datatype as the
%   field.
%
%   This function corresponds to the GDsetfillvalue function in the HDF-EOS
%   library C API.
%
%   Example:  Create a new double precision field with a fill value of -1.
%       import matlab.io.hdfeos.*
%       srcFile = fullfile(matlabroot,'toolbox','matlab','imagesci','grid.hdf');
%       copyfile(srcFile,'myfile.hdf');
%       fileattrib('myfile.hdf','+w');
%       gfid = gd.open('myfile.hdf','rdwr');
%       gridID = gd.attach(gfid,'PolarGrid');
%       gd.defComp(gridID,'none');
%       gd.defField(gridID,'newfield',{'XDim','YDim'},'double'); 
%       gd.setFillValue(gridID,'newfield',-1);
%       gd.detach(gridID);
%       gd.close(gfid);
%  
%   See also gd, gd.getFillValue.

%   Copyright 2010-2013 The MathWorks, Inc.

status = hdf('GD','setfillvalue',gridID,fieldName,fillValue);
hdfeos_gd_error(status,'GDsetfillvalue');
