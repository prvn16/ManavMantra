function [ntype,dims] = periodInfo(swathID,periodID,fieldName)
%periodInfo Retrieve information about subsetted period.
%   [DATATYPE,DIMS] = periodInfo(swathID,periodID,fieldName) retrieves
%   information about the period defined for the given field.  DATATYPE is
%   the datatype of the field.  DIMS is the dimensions of the subsetted
%   region.
%
%   This function corresponds to the SWperiodinfo function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   dims parameter is reversed with respect to the C library API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       starttime =  25;
%       stoptime = 425;
%       periodID = sw.defTimePeriod(swathID,starttime,stoptime,'MIDPOINT');
%       [ntype,dims] = sw.periodInfo(swathID,periodID,'Temperature');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defTimePeriod, sw.extractPeriod.

%   Copyright 2010-2013 The MathWorks, Inc.

[ntype,~,dims,~,status] = hdf('SW','periodinfo',swathID,periodID,fieldName);
hdfeos_sw_error(status,'SWperiodinfo');

% Reverse because of majority.
dims = fliplr(dims(:)');

switch(ntype)
    case 'float'
        ntype = 'single';
    case 'float64'
        ntype = 'double';
end
