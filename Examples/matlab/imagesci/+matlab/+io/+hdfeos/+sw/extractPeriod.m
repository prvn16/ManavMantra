function data = extractPeriod(swathID,periodID,fieldName)
%extractPeriod Read data from subsetted time period.
%   DATA = extractPeriod(swathID,periodID,FIELDNAME) reads data for the 
%   given field for the time period specified by periodID.
%   
%   This routine corresponds to the SWextractperiod function in the HDF-EOS 
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       starttime =  25;
%       stoptime = 425;
%       periodID = sw.defTimePeriod(swathID,starttime,stoptime,'MIDPOINT');
%       data = sw.extractPeriod(swathID,periodID,'Temperature');
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defTimePeriod.

%   Copyright 2010-2013 The MathWorks, Inc.

[data,status] = hdf('SW','extractperiod',swathID,periodID,fieldName,'HDFE_INTERNAL');
hdfeos_sw_error(status,'SWextractperiod');
