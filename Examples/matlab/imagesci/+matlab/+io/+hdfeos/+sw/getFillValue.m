function fillvalue = getFillValue(swathID,fieldname)
%getFillValue  Retrieve fill value for specified field.
%   FILLVALUE = getFillValue(swathID,FIELDNAME) retrieves the fill value 
%   for the specified field.
%
%   This function corresponds to the SWgetfillvalue function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       fv = sw.getFillValue(swathID,'Spectra');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.setFillValue.

%   Copyright 2010-2013 The MathWorks, Inc.


% Verify that the swath ID and fieldName are at least valid.
try
    matlab.io.hdfeos.sw.fieldInfo(swathID,fieldname);
catch me
    if strcmp(me.identifier,'MATLAB:imagesci:hdfeos:hdfEosLibraryError')
        error(message('MATLAB:imagesci:hdfeos:invalidSwathOrField', fieldname));
    else
        rethrow(me);
    end
end

[fillvalue,status] = hdf('SW','getfillvalue',swathID,fieldname);
hdfeos_sw_error(status,'SWgetfillvalue');
