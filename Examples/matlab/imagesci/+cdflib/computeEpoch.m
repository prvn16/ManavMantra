function epoch = computeEpoch(time)
%cdflib.computeEpoch Convert time value to EPOCH value
%   epoch = cdflib.computeEpoch(timeval) returns an EPOCH value given the 
%   individual components timeval.  timeval must have seven components:
%
%     year     - year (AD, e.g., 1994)
%     month    - month (1-12)
%     day      - day (1-31)
%     hour     - hour (0-23)
%     minute   - minute (0-59)
%     second   - second (0-59)
%     msec     - millisecond (0-999)
%
%   Example:
%     timeval = [1999 12 31 23 59 59 0];
%     epoch = cdflib.computeEpoch(timeval);
%
%   The output is a double precision value.
%
%   This function corresponds to the CDF library C API routine 
%   computeEPOCH.
%
%   Example:
%       timeval = [1999 12 31 23 59 59 0];
%       epoch = cdflib.computeEpoch(timeval);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib.computeEpoch16, cdflib.epochBreakdown, cdflib.epoch16Breakdown.

%   Copyright 2009-2013 The MathWorks, Inc.

epoch = cdflibmex('computeEpoch',time);
