function writeAttr(swathID,attrName,data)
%writeAttr Write swath attribute.
%   writeAttr(swathID,ATTRNAME,DATA) writes an attribute to a swath.  If
%   the attribute does not exist, it is created.  If the attribute exists,
%   it may be modified in place, but it may not recreated with a different 
%   datatype or length.
%
%   This function corresponds to the SWwriteattr function in the HDF-EOS
%   library C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'MySwath');
%       sw.writeAttr(swathID,'creation_date', datestr(now));
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.readAttr.

%   Copyright 2010-2013 The MathWorks, Inc.


status = hdf('SW','writeattr',swathID,attrName,data);
hdfeos_sw_error(status,'SWwriteattr');
