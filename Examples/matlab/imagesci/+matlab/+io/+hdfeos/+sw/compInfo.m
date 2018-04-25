function [compCode,compParm] = compInfo(swathID,fieldName)
%compInfo Retrieve compression information for field
%   [CODE,PARMS] = compInfo(swathID,FIELDNAME) retrieves the compression 
%   code and compression parameters for a given field.  Refer to sw.defComp
%   for a description of various compression schemes and parameters.
%
%   This function corresponds to the SWcompinfo function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       [compCode,parms] = sw.compInfo(swathID,'Spectra');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defComp.

%   Copyright 2010-2013 The MathWorks, Inc.

% Verify that the swath ID and fieldName are valid.
try
    matlab.io.hdfeos.sw.fieldInfo(swathID,fieldName);
catch me
    if strcmp(me.identifier,'MATLAB:imagesci:hdfeos:hdfEosLibraryError')
        error(message('MATLAB:imagesci:hdfeos:invalidSwathOrField', fieldName));
    else
        rethrow(me);
    end
end

[compCode,compParm,status] = hdf('SW','compinfo',swathID,fieldName);
if status < 0
    compCode = 'none';
    compParm = [];
end 
switch(compCode)
    case {'rle', 'none'}
        compParm = [];
    case {'deflate', 'skphuff'}
        compParm = compParm(1);
end
        
