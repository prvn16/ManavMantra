function tsprops(ts)
%TIME SERIES OBJECT PROPERTIES:
%
%      Events:  information about events that associate with the time series,
%               including the following properties: (See ADDEVENT for more
%               information about adding an event to a time series object)
%
%               EventData:  use this property to include any additional
%                           user-defined information about the event
%               Name:       a string giving the name of the event
%               Time:       the time at which this event occurs
%               Units:      time units
%               StartDate:  reference date
%
%      Name:    a string defining the name of the time series object
%
%      Data:    a numerical array of data
%
%      DataInfo: meta information about the data, including the following
%                properties: 
%
%               Unit:       a user-defined string describing the units for the data
%               Interpolation:  a tsdata.interpolation object defining
%                               default interpolation method used in time 
%                               series. The interpolation object includes
%                               the following properties: 
%                       Fhandle:    the function handle to the interpolation function
%                       Name:       name of the interpolation method.
%                                   Typically either 'zoh' or 'linear' (default).
%               UserData:  stores any additional user-defined information
%
%      Time:    a vector of times
%
%      TimeInfo: meta information about the times, including the following
%                properties:
%
%               Units: 'weeks','days','hours','minutes','seconds', ...
%                       'milliseconds', 'microseconds' and 'nanoseconds'
%               Start: start time
%               End: end time
%               Increment: interval between two subsequent time values
%               Length: number of times in the time vector
%               Format: a string defining the date string display format. 
%                       Refer to DATESTR for available options.
%               Startdate: a date string defining the reference date. The
%                       times in the time vector are all relative to this
%                       date. See SETABSTIME for more information. 
%               UserData:  stores any additional user-defined information
%
%      Quality: an integer array describing the quality of the data.
%
%      QualityInfo: meta information about the quality code, including the following
%                   properties:
%               Codes:  a vector of int8 integers defining the set of
%                       quality codes
%               Desription: a cell array of strings, each giving a
%                       description of the associated quality code
%               UserData:  stores any additional user-defined information
%
%      IsTimeFirst: True when the first dimension of the data array is
%                   aligned with the Time. False when the last dimension of
%                   the data array is aligned with Time. The default value is 
%                   False for 3-D and higher dimensional data and True otherwise
%                   Note, this property is Read-Only.
%
%      TreatNaNasMissing: True (default) when all the NaN values in TS.Data
%                   will be treated as missing data and excluded during
%                   statistical calculations. False when those NaN values
%                   will be used in the calculation.
%

%   Copyright 2004-2013 The MathWorks, Inc.

