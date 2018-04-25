function [wasSpecified,rowTimes,startTime,timeStep,samplingRate] = validateTimeVectorParams(supplied,rowTimes,startTime,timeStep,samplingRate)
% VALIDATETIMEVECTORPARAMS process the StartTime, TimeStep, and SamplingRate
% parameters to the timetable constructor and other functions

%   Copyright 2017 The MathWorks, Inc.
import matlab.internal.datatypes.isScalarText
import matlab.internal.datetime.text2timetype

try

wasSpecified = true;
if supplied.RowTimes
    if supplied.SamplingRate || supplied.TimeStep || supplied.StartTime
        % RowTimes is mutually exclusive with SamplingRate, TimeStep, and StartTime
        error(message('MATLAB:timetable:RowTimesParamConflict'));
    end
elseif supplied.SamplingRate
    if supplied.RowTimes || supplied.TimeStep
        % SamplingRate is mutually exclusive with RowTimes and TimeStep
        error(message('MATLAB:timetable:RowTimesParamConflict'));
    elseif ~(isnumeric(samplingRate) && isscalar(samplingRate) && (samplingRate > 0))
        % SamplingRate must be a positive scalar number
        error(message('MATLAB:timetable:InvalidSamplingRate'));
    end
    samplingRate = double(samplingRate);
    % StartTime is optional with SamplingRate, can be a datetime or a duration
elseif supplied.TimeStep
    if supplied.RowTimes || supplied.SamplingRate
        % TimeStep is mutually exclusive with RowTimes and SamplingRate
        error(message('MATLAB:timetable:RowTimesParamConflict'));
    elseif isnumeric(timeStep)
        % Give a helpful error for numeric
        error(message('MATLAB:timetable:InvalidTimeStepNumeric'));
    elseif isScalarText(timeStep)
        timeStep = text2timetype(timeStep,'MATLAB:datetime:InvalidTextInput');
        % This falls through to the duration or calendarDuration cases.
    elseif ~isscalar(timeStep)
        % duration or calendarDuration timeStep must be a scalar
        error(message('MATLAB:timetable:InvalidTimeStep'));
    end
    if isa(timeStep,'duration')
        % StartTime is optional with TimeStep
        if ~supplied.StartTime % default startTime is a duration
            % Default format is 's', adjust that to a timer format if the time step is
            % a whole number of seconds.
            secs = seconds(timeStep);
            if round(secs) == secs
                startTime.Format = 'hh:mm:ss';
            end
        end
    elseif isa(timeStep,'calendarDuration')
        % StartTime is required if TimeStep is a calendarDuration
        if ~supplied.StartTime
            error(message('MATLAB:timetable:DurationStartTimeWithCalDurTimeStep'));
        end
        % A calendarDuration TimeStep must be "pure", only one unit
        [m,d,t] = split(timeStep,{'months' 'days' 'time'});
        if sum((m~=0) + (d~=0) + (t~=0)) ~= 1
            error(message('MATLAB:timetable:ImpureCalDurTimeStep'));
        end
    else
        % TimeStep must be a duration or calendarDuration
        error(message('MATLAB:timetable:InvalidTimeStep'));
    end
else % neither RowTimes, nor TimeStep, nor SamplingRate was provided
    wasSpecified = false;
end

% By now, if StartTime has been supplied, it must have been with TimeStep or SamplingRate
if supplied.StartTime % && ~supplied.RowTimes
    if isnumeric(startTime)
        % Give a helpful error for numeric
        error(message('MATLAB:timetable:InvalidStartTimeNumeric'));
    elseif isScalarText(startTime)
        startTime = text2timetype(startTime,'MATLAB:datetime:InvalidTextInput');
        % Falls through to datetime check
    elseif ~isscalar(startTime) || ~(isdatetime(startTime) || isduration(startTime))
        % TimeStep must be a scalar duration or datetime
        error(message('MATLAB:timetable:InvalidStartTime'));
    end
    % Make sure a calendarDuration TimeStep has a datetime StartTime
    if supplied.TimeStep && isa(timeStep,'calendarDuration') && ~isa(startTime,'datetime')
        error(message('MATLAB:timetable:DurationStartTimeWithCalDurTimeStep'));
    end
end

catch ME, throwAsCaller(ME); end
