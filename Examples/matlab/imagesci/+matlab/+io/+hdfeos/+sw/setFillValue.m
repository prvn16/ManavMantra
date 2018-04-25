function setFillValue(swathID,fieldName,fillValue)
%setFillValue Set the fill value for the specified field.
%   setFillValue(swathID,FIELDNAME,FILLVALUE) sets the fill value for the
%   specified field.  The field must have more than two dimensions.
%
%   This function corresponds to the SWsetfillvalue function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('myfile.hdf','create');
%       swathID = sw.create(swfid,'MySwath');
%       sw.defDim(swathID,'Track',400);
%       sw.defDim(swathID,'Xtrack',200);
%       dims = {'Track','Xtrack'};
%       sw.defDataField(swathID,'Temperature',dims,'float');
%       sw.setFillValue(swathID,'Temperature',single(-999));
%       sw.detach(swathID);
%       sw.close(swfid);
% 
%   See also sw, sw.getFillValue.

%   Copyright 2010-2013 The MathWorks, Inc.

validateattributes(fillValue,{'numeric','char'},{'scalar'},'','FILLVALUE');

status = hdf('SW','setfillvalue',swathID,fieldName,fillValue);
hdfeos_sw_error(status,'SWsetfillvalue');
