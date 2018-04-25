function tt = array2timetable(x,varargin)
%ARRAY2TIMETABLE Convert homogeneous array to timetable.
%   TT = ARRAY2TIMETABLE(X,'RowTimes',ROWTIMES) converts the M-by-N array X and
%   the M-by-1 datetime or duration vector ROWTIMES to an M-by-N timetable TT. Each
%   column of X becomes a variable in TT, and ROWTIMES becomes TT's time vector.
%
%   Note: to convert a table to a timetable, use TABLE2TIMETABLE.
%
%   TT = ARRAY2TIMETABLE(X,'RowTimes',ROWTIMES,'VariableNames',VARNAMES) creates
%   TT using the cell array of character vectors VARNAMES for TT's variable
%   names. The names must be valid MATLAB identifiers, and must be unique.
%
%   TT = ARRAY2TIMETABLE(X,'SamplingRate',FS,'StartTime',T0) creates a timetable
%   using the specified sampling rate FS and start time T0 to implicitly define
%   TT's time vector. FS is a positive numeric scalar specifying the number of
%   samples per second (Hz). T0 is a scalar datetime or duration, and determines
%   whether TT's row times are absolute (T0 is a datetime) or relative (T0 is a
%   duration). The default is SECONDS(0).
%
%   TT = ARRAY2TIMETABLE(X,'TimeStep',DT,'StartTime',T0) creates a timetable
%   using the specified time step DT and start time T0 to implicitly define TT's
%   time vector. DT is a scalar duration or calendarDuration specifying the
%   inter-sample time step. T0 is a scalar datetime or duration, and determines
%   whether TT's row times are absolute (T0 is a datetime) or relative (T0 is a
%   duration). T0 must be a datetime if DT is a calendarDuration. The default is
%   SECONDS(0).
%
%   See also TIMETABLE, TABLE2TIMETABLE, ARRAY2TABLE, CELL2TABLE, STRUCT2TABLE.

%   Copyright 2016-2017 The MathWorks, Inc.

import matlab.internal.tabular.validateTimeVectorParams

if ~ismatrix(x)
    error(message('MATLAB:array2timetable:NDArray'));
end
[nrows,nvars] = size(x);
vars = mat2cell(x,nrows,ones(1,nvars));

pnames = {'VariableNames' 'RowTimes'  'SamplingRate'    'TimeStep'  'StartTime'};
dflts =  {            []         []              []            []   seconds(0) };
[varnamesArg,rowtimes,samplingRate,timeStep,startTime,supplied] ...
    = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

rowtimesName = 'Time';
[rowtimesDefined,rowtimes,startTime,timeStep,samplingRate] = validateTimeVectorParams(supplied,rowtimes,startTime,timeStep,samplingRate);
if ~rowtimesDefined % neither RowTimes, TimeStep, nor SamplingRate was specified
    error(message('MATLAB:array2timetable:RowTimeRequired'));
end
if supplied.RowTimes
    % ok
elseif supplied.TimeStep
    rowtimes = matlab.internal.tabular.private.rowTimesDim.regularRowTimesFromTimeStep(startTime,timeStep,nrows);
else % supplied.SamplingRate
    rowtimes = matlab.internal.tabular.private.rowTimesDim.regularRowTimesFromSamplingRate(startTime,samplingRate,nrows);
end

if supplied.VariableNames
    varnames = varnamesArg;
else
    baseName = inputname(1);
    if isempty(baseName) || (nvars == 0)
        varnames = matlab.internal.tabular.defaultVariableNames(1:nvars);
    else
        if nvars == 1
            varnames = {baseName};
        else
            varnames = matlab.internal.datatypes.numberedNames(baseName,1:nvars);
        end
    end
end

% The input matrix defines the size of the output timetable. The time
% vector must have the same length as the matrix has rows, even if
% the matrix has no columns.
if numel(rowtimes) ~= nrows
    error(message('MATLAB:array2timetable:IncorrectNumberOfRowTimes'));
end

% Each column of x becomes a variable in t
tt = timetable.init(vars, nrows, rowtimes, nvars, varnames);
% Assignment forces checking for a clash with var names.
tt.Properties.DimensionNames{1} = rowtimesName;