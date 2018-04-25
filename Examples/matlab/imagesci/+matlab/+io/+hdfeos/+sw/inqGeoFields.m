function [fields,rank,datatype] = inqGeoFields(swathID)
%inqGeoFields Retrieve information about geolocation fields.
%   [FIELDS,RANK,DATATYPE] = inqGeoFields(swathID) returns the list of
%   geolocation fields FIELDS, the rank of each field, and the datatype of
%   each field.
%
%   This function corresponds to the SWinqgeofields function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   FIELDS parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       [fields,rank,datatypes] = sw.inqGeoFields(swathID);
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defGeoField, sw.inqDataFields.

%   Copyright 2010-2013 The MathWorks, Inc.

[nfields,rfields,rank,datatype] = hdf('SW','inqgeofields',swathID);
if nfields == 0
    fields = {};
    rank = [];
    datatype = '';
elseif nfields < 0
    hdfeos_sw_error(nfields,'SWinqgeofields');
else
    for j = 1:numel(datatype)
        if strcmp(datatype{j},'float')
            datatype{j} = 'single';
        end
    end
    fields = regexp(rfields,',','split');
    fields = fields';
end

