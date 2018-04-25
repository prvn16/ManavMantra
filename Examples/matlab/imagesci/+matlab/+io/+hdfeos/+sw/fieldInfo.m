function [dimsizes,ntype,dimlist] = fieldInfo(swathID,fieldName)
%fieldInfo  Return information about swath field.
%   [DIMSIZES,NTYPE,DIMLIST] = fieldInfo(swathID,FIELDNAME) returns the
%   size, datatype, and list of named dimensions for the specified swath
%   geolocation or data field.
%
%   This function corresponds to the SWfieldinfo function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   dimlist parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       [fieldSize,ntype,dimlist] = sw.fieldInfo(swathID,'Spectra');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.inqGeoFields, sw.inqDataFields.

%   Copyright 2010-2015 The MathWorks, Inc.

[~,dimsizes,ntype,rdimlist,status] = hdf('SW','fieldinfo',swathID,fieldName);
hdfeos_sw_error(status,'SWfieldinfo');

% Reverse the order of fieldsize because of majority issue.
dimsizes = fliplr(dimsizes);
dimlist = regexp(rdimlist,',','split');
dimlist = fliplr(dimlist);

if strcmp(ntype,'float')
    ntype = 'single';
end
