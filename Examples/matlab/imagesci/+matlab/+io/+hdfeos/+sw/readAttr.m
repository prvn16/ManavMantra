function data = readAttr(swathID,attrName)
%readAttr Read swath attribute.
%   data = readAttr(SWATHID,ATTRNAME) reads a swath attribute.
%
%   This function corresponds to the SWreadAttr function in the HDF-EOS
%   library C API.
%
%   Example:    
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       value = sw.readAttr(swathID,'creation_date');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.writeAttr.

%   Copyright 2010-2013 The MathWorks, Inc.

[data, status] =hdf('SW','readattr',swathID,attrName);
hdfeos_sw_error(status,'SWreadattr');

% make the character attributes human-readable.
if ischar(data)
    data = data';
end
