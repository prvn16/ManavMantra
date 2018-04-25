function periodID = defTimePeriod(swathID,startTime,stopTime,mode)
%defTimePeriod Define time period of interest
%   OUTPID = defTimePeriod(swathID,START,STOP,MODE) defines a time period 
%   for a swath.  OUTPID is a swath period ID that may be used to read all 
%   the entrieds of a data field within the time period.  The swath 
%   structure must have the 'Time' field defined.   A cross track is within 
%   a time period if a condition is met according to the value of MODE.
% 
%       'MIDPOINT' - the midpoint is within the time period
%       'ENDPOINT' - either endpoint is within the time period
%
%   The swath structure must have the 'Time' field defined.
%
%   This function corresponds to the SWdeftimeperiod function in the
%   HDF-EOS library C API.
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
%   See also sw, sw.defBoxRegion, sw.defVrtRegion, sw.extractPeriod.

%   Copyright 2010-2013 The MathWorks, Inc.

validateattributes(mode,{'char'},{'nonempty'},'','MODE');
mode = validatestring(mode,{'midpoint','endpoint','hdfe_midpoint','hdfe_endpoint'});
switch(lower(mode))
    case {'midpoint','endpoint'}
    case 'hdfe_midpoint' 
        mode = 'midpoint';
    case 'hdfe_endpoint' 
        mode = 'endpoint';
end
periodID = hdf('SW','deftimeperiod',swathID,startTime,stopTime,mode);
hdfeos_sw_error(periodID,'SWdeftimeperiod');
