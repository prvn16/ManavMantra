function [attrName,datatype,nelts] = attrInfo(objID,idx)
%attrInfo Return information about attribute.
%   [NAME,DATATYPE,NELTS] = attrInfo(objID,IDX) returns the name,
%   datatype, and number of elements in the specified attribute.  The
%   attribute is specified by its zero-based index value.  objID may be
%   either an SD interface identifier, a data set identifier, or a dimension
%   identifier.
%
%   This function corresponds to the SDattrinfo function in the HDF library
%   C API.
%
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       idx = sd.findAttr(sdID,'creation_date');
%       [name,datatype,nelts] = sd.attrInfo(sdID,idx);
%       data = sd.readAttr(sdID,idx);
%       sd.close(sdID);
%
%   See also sd, sd.findAttr.

%   Copyright 2010-2013 The MathWorks, Inc.

[attrName,datatype,nelts,status] = hdf('SD','attrinfo',objID,idx);
if status < 0 
    hdf4_sd_error('SDattrinfo');
end

% Make datatype translations into MATLAB equivalents where appropriate.
switch(datatype)
    case 'char8'
        datatype = 'char';
end
