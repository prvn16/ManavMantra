function timev = epoch16Breakdown(epoch16Time)
%cdflib.epoch16Breakdown Decompose EPOCH16 value
%   timeVec = cdflib.epoch16Breakdown(epoch16Time) decomposes an EPOCH16 
%   value into individual components.  timeVec will have 10 x n elements,
%   where n is the number of epoch16 values.
%
%     timeVec(1,:)  = year AD, e.g., 1994
%     timeVec(2,:)  = month, 1-12
%     timeVec(3,:)  = day, 1-31
%     timeVec(4,:)  = hour, 0-23
%     timeVec(5,:)  = minute, 0-59
%     timeVec(6,:)  = second, 0-59
%     timeVec(7,:)  = msec, 0-999
%     timeVec(8,:)  = microsec, 0-999
%     timeVec(9,:)  = nanosec, 0-999
%     timeVec(10,:) = picosec, 0-999
%
%   This function corresponds to the CDF library C API routine 
%   EPOCH16breakdown.
%
%   Example:
%       timeval = [1999; 12; 31; 23; 59; 59; 50; 100; 500; 999];
%       epoch16 = cdflib.computeEpoch16(timeval);
%       timevec = cdflib.epoch16Breakdown(epoch16);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.computeEpoch16.


%   Copyright 2009-2013 The MathWorks, Inc.

timev = cdflibmex('epoch16Breakdown',epoch16Time);

