function attrList = inqAttrs(swathID)
%inqAttrs Retrieve names of swath attributes.
%   ATTRLIST = inqAttrs(swathID) returns the list of swath attribute names.  
%   ATTRLIST is a cell array.
%
%   This function corresponds to the SWinqattrs function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       attrList = sw.inqAttrs(swathID);
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.readAttr, sw.writeAttr.

%   Copyright 2010-2013 The MathWorks, Inc.

try
    matlab.io.hdfeos.sw.inqDims(swathID);
catch me
    error(message('MATLAB:imagesci:hdfeos:invalidSwathID'));
end

[nattrs,rattrs] = hdf('SW','inqattrs',swathID);
hdfeos_sw_error(nattrs,'SWinqattrs');

attrList = regexp(rattrs,',','split');
attrList = attrList';
