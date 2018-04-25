function [dims,ntype,dimlist] = fieldInfo(gridID,fieldName)
%fieldInfo Retrieve information about data field.
%   [DIMS,NTYPE,DIMLIST] = fieldInfo(gridID,FIELDNAME) returns 
%   information about a specific geolocation or data field in the grid.
%   DIMS is a vector containing the dimension sizes of the field. NTYPE is 
%   a string containing the HDF number type of the field. DIMLIST is a cell 
%   array of strings containing the list of dimension names.  
%
%   This function corresponds to the GDfieldinfo function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   dimlist parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [dims,ntype,dimlist] = gd.fieldInfo(gridID,'ice_temp');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defField.

%   Copyright 2010-2013 The MathWorks, Inc.

[~,dims,ntype,rdimlist,status] = hdf('GD','fieldinfo',gridID,fieldName);
hdfeos_gd_error(status,'GDfieldinfo');

% Flip because of row-col-major-order issue.
dims = fliplr(dims);
dimlist = regexp(rdimlist,',','split');
dimlist = fliplr(dimlist);

% switch NTYPE to matlab.
switch(ntype)
    case 'float'
        ntype = 'single';
    case 'float64'
        ntype = 'double';
end
