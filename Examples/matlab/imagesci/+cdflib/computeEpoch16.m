function epoch = computeEpoch16(time)
%cdflib.computeEpoch16 Convert time value to EPOCH16 value
%   epoch16 = cdflib.computeEpoch16(timeval) converts a 10x1 time value 
%   array to the EPOCH16 representation.  Multiple time values can be
%   specified by using additional columns.  The meaning of each such 
%   element is as follows:
%
%     year     - year (AD, e.g., 1994)
%     month    - month (1-12)
%     day      - day (1-31)
%     hour     - hour (0-23)
%     minute   - minute (0-59)
%     second   - second (0-59)
%     msec     - millisecond (0-999)
%     microsec - microsecond (0-999)
%     nanosec  - nanosecond (0-999)
%     picosec  - picosecond (0-999)
%
%   Example:
%     timeval = [1999; 12; 31; 23; 59; 59; 50; 100; 500; 999];
%     epoch16 = cdflib.computeEpoch16(timeval);
%
%   If timeval has m*10 elements, then epoch16 will have size 2-by-m.
%
%   This function corresponds to the CDF library C API routine 
%   computeEPOCH16.
%
%   Example:
%       timeval = [1999 12 31 23 59 59 50 100 500 999];
%       epoch16 = cdflib.computeEpoch16(timeval);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.computeEpoch, cdflib.epochBreakdown, 
%   cdflib.epoch16Breakdown.

%   Copyright 2009-2013 The MathWorks, Inc.

epoch = cdflibmex('computeEpoch16',time);
