function attrList = inqAttrs(gridID)
%inqAttrs Retrieve names of grid attributes.
%   ATTRLIST = inqAttrs(gridID) returns the list of grid attribute
%   names.  ATTRLIST will be a cell array.
%
%   This function corresponds to the GDinqattrs function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       attrList = gd.inqAttrs(gridID);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.readAttr, gd.writeAttr.

%   Copyright 2010-2013 The MathWorks, Inc.

try
    matlab.io.hdfeos.gd.gridInfo(gridID);
catch me
    error(message('MATLAB:imagesci:hdfeos:invalidGrid'));
end

[nattrs,rattrs] = hdf('GD','inqattrs',gridID);
hdfeos_gd_error(nattrs,'GDinqattrs');

if nattrs == 0
    attrList = {};
    return
end
attrList = regexp(rattrs,',','split');
attrList = attrList';
