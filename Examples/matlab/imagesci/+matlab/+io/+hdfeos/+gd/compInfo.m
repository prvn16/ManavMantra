function [compCode,compParm] = compInfo(gridID,fieldName)
%compInfo Retrieve compression information for field.
%   [COMPCODE,PARMS] = compInfo(GID,FIELDNAME) retrieves the compression 
%   code and compression parameters for a given field.  Refer to gd.defComp
%   for a description of various compression schemes and parameters.
%
%   This function corresponds to the GDcompinfo function in the HDF-EOS
%   library C API.
%
%   Example:  Get compression information for the 'ice_temp' field.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [compCode,compParms] = gd.compInfo(gridID,'ice_temp');
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defComp.

%   Copyright 2010-2014 The MathWorks, Inc.

try
    matlab.io.hdfeos.gd.gridInfo(gridID);
catch ALL
    error(message('MATLAB:imagesci:hdfeos:invalidGrid'));
end
try
    matlab.io.hdfeos.gd.fieldInfo(gridID,fieldName);
catch ALL
    error(message('MATLAB:imagesci:hdfeos:invalidField', fieldName));
end

[compCode,compParm,status] = hdf('GD','compinfo',gridID,fieldName);
if status < 0
    % We know the field is present.  Assume no compression.
    compCode = 'none';    
end

switch(compCode)
    case {'skphuff', 'deflate'}
        compParm = compParm(1);
    case {'rle', 'none'}
        compParm = [];
end
