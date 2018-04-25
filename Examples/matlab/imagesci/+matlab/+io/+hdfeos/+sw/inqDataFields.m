function [fields,rank,datatype] = inqDataFields(swathID)
%inqDataFields Retrieve information about geolocation fields.
%   [FIELDS,RANK,DATATYPE] = inqDataFields(swathID) returns the list of
%   geolocation field names, the rank of each field, and the datatype of
%   each field.
%
%   This function corresponds to the SWinqdatafields function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   FIELDS parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       [fields,rank,datatype] = sw.inqDataFields(swathID);
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defDataField, sw.inqGeoFields.

%   Copyright 2010-2015 The MathWorks, Inc.

[nfields,rfields,rank,datatype] = hdf('SW','inqdatafields',swathID);
hdfeos_sw_error(nfields,'SWinqdatafields');

if nfields == 0
    fields = {};
    rank = [];
    datatype = '';
else
    
    % Map hdf types to MATLAB.
    for j = 1:numel(datatype)
        switch datatype{j}
            case {'float', 'float32'}
                datatype{j} = 'single';
            case {'float64'}
                datatype{j} = 'double';
            case {'char8','uchar8'}
                datatype{j} = 'char';
        end

    end
    fields = regexp(rfields,',','split');
    fields = fields';
end

