function tt2 = retime(tt1,newTimes,method,varargin)
%RETIME Adjust a timetable and its data to a new vector of row times.
%   RETIME replaces a timetable's row times and adjusts its data to account for
%   aligning to the new row times. To synchronize two or more timetables to a new
%   vector of row times, use SYNCHRONIZE, or use RETIME on each one and then
%   horizontally concatenate.
%
%   TT2 = RETIME(TT1,NEWTIMES) creates a timetable TT2 that contains the same
%   set of variables as TT1, but whose row times are NEWTIMES. NEWTIMES must be
%   sorted and contain unique values.
% 
%   Where NEWTIMES matches row times in TT1, TT2's variables contain the same
%   data as the corresponding rows in TT1. Where NEWTIMES does not match row
%   times in TT1, TT2's variables contain missing data indicators. For example,
%   when NEWTIMES is a subset of TT1's row times, TT2 contains a subset of
%   TT1's rows. When NEWTIMES is a superset, TT2 contains all the rows from TT1,
%   plus extra rows containing missing data indicators. However, NEWTIMES may be
%   more general.
%
%   If you specify the VariableContinuity property of TT1, RETIME fills in
%   or interpolates values in TT2 according to the values specified in
%   VariableContinuity. Using the VariableContinuity property, you can
%   specify whether each timetable variable represents continuous, step, or
%   event data. For each variable, RETIME then uses one of the following
%   methods to fill in or interpolate values:
%
%   VariableContinuity              Default Method
%   ------------------              ---------------
%   unset                           fillwithmissing
%   continuous                      linear
%   step                            previous
%   event                           fillwithmissing
%
%   TT2 = RETIME(TT1,NEWTIMESTEP) creates TT2 with row times that are
%   regularly-spaced by the time unit specified by NEWTIMESTEP, and that spans the
%   range of times in TT1's row times. NEWTIMESTEP is 'yearly', 'quarterly',
%   'monthly', 'weekly', 'daily', 'hourly', 'minutely', or 'secondly'.
% 
%   TT2 = RETIME(TT1,'regular','TimeStep',DT) creates TT2 with row times that
%   are regularly-spaced with the specified time step DT, and that span the
%   range of times in TT1's row times. DT is a scalar duration or
%   calendarDuration.
% 
%   TT2 = RETIME(TT1,'regular','SamplingRate',FS) creates TT2 with row times
%   that are regularly-spaced with the specified sampling rate FS, and that span
%   the range of times in TT1's row times. FS is a positive scalar numeric
%   value.
% 
%   TT2 = RETIME(TT1,NEWTIMES,METHOD),
%   TT2 = RETIME(TT1,NEWTIMESTEP,METHOD),
%   TT2 = RETIME(TT1,'regular',METHOD,'TimeStep',DT), or
%   TT2 = RETIME(TT1,'regular',METHOD,'SamplingRate',FS) 
%   create new data for unmatched rows in TT2 by adjusting the data from TT1 onto
%   the new time vector, rather than inserting missing data indicators. METHOD
%   specifies a function used to convert TT1's data to the new time vector. For
%   example, when NEWTIMES is equal to TT1's row times plus an offset, and METHOD
%   is 'spline', TT2 is a "shifted" version of TT1 with interpolated data.
%
%   If the VariableContinuity property of the input timetable is set, then
%   METHOD overrides the values in VariableContinuity. RETIME applies METHOD
%   to every timetable variable.
%
%   METHOD is a character vector from one of the following categories:
% 
%      Filling methods: fill unmatched rows in TT2 as specified.
%         'fillwithmissing'  - (default) fill with missing data indicators
%         'fillwithconstant' - fill with the value of the 'Constant' parameter
% 
%      Nearest neighbor methods: copy data from TT1 into unmatched rows in TT2.
%      TT1 must be sorted by time.
%         'previous' - copy data from the nearest preceding neighbor in TT1
%         'next'     - copy data from the nearest following neighbor in TT1
%         'nearest'  - copy data from the nearest neighbor in TT1
% 
%      Interpolation methods: fill unmatched rows in TT2 by interpolating data
%      from neighboring rows in TT1. TT1 must be sorted by time and contain
%      unique times. Use the 'EndValues' parameter to control how the data are
%      extrapolated.
%         'linear' - use linear interpolation
%         'spline' - use piecewise cubic spline interpolation
%         'pchip'  - use shape-preserving piecewise cubic interpolation
% 
%      Aggregation methods: fill rows in TT2 by aggregating data from TT1, using the
%      time bins defined by NEWTIMES. RETIME assigns the left edges of the bins as
%      TT2's row times. When NEWTIMES is provided, the last row of TT2 consists of
%      only the data that exactly matches the last time value. Use the 'IncludedEdge'
%      parameter to control which bin edges are assigned.  The listed methods omit
%      NaNs, NaTs, and other missing data indicators when aggregating data. To
%      include missing data indicators, specify the method as a function handle to a
%      function that includes them when aggregating data.  @fun applies a function to
%      all data in each bin, including missing values.
%         'sum'          - use the sum of values in each bin
%         'mean'         - use the mean of values in each bin
%         'prod'         - use the product of values in each bin
%         'min'          - use the minimum value in each bin
%         'max'          - use the maximum value in each bin
%         'firstvalue'   - use the first value in each bin
%         'lastvalue'    - use the last value in each bin
%         @fun           - use the specified function
% 
%   METHOD can also be 'default'. This is equivalent to using 'fillwithmissing'
%   for variables whose VariableContinuity property is not set, or using the
%   method corresponding to the VariableContinuity property setting.
% 
%   TT2 = RETIME(..., 'PARAM1',val1, 'PARAM2',val2, ...) allows you to specify
%   optional parameter name/value pairs. Parameters are:
%   
%         'Constant'     - the constant value used with 'fillwithconstant'.
%                          Default is 0.
%         'EndValues'    - the extrapolation method used for 'next', 'previous',
%                          'nearest', 'linear', 'spline', and 'pchip'. Values
%                          are 'extrap' (default) to use METHOD to extrapolate,
%                          or a scalar value to extrapolate with a constant.
%         'IncludedEdge' - specifies which bin edges are included in the time bins
%                          used in the aggregation methods. Values are 'left' (the
%                          default) to include the left bin edges, except for the
%                          last bin which includes both edges, and 'right' to
%                          include the right bin edges, except for the first bin
%                          which includes both edges. 'IncludedEdge' also controls
%                          which bin edges are returned as TT2's row times.
%
%   See also SYNCHRONIZE, INNERJOIN, OUTERJOIN, HORZCAT, VERTCAT.

%   Copyright 2016-2017 The MathWorks, Inc.

% fend off 
if any(strcmpi(newTimes,{'union', 'intersection', 'commonrange', 'first', 'last'}))
    error(message('MATLAB:timetable:synchronize:InvalidNewTimesForRetime'))
end

try %#ok<ALIGN>
if nargin == 2
    tt2 = synchronize(tt1,newTimes);
elseif nargin == 3
    tt2 = synchronize(tt1,newTimes,method);
else
    tt2 = synchronize(tt1,newTimes,method,varargin{:});
end
catch ME, throw(ME); end % keep the stack trace to one level