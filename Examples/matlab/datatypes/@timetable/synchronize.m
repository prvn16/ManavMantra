function ttOut = synchronize(varargin)
%SYNCHRONIZE Synchronize timetables.
%   SYNCHRONIZE provides a way to, in effect, horizontally concatenate two or
%   more timetables even when their row times are different. You can retain
%   all the times from the input timetables in the output, or synchonize one
%   timetable to another, or specify a completely new vector of row times for the
%   output. SYNCHRONIZE also provides several ways to adjust each timetable's
%   data to account for aligning to a different vector of row times.
%
%   To adjust one timetable and its data to new row times, use RETIME.
%
%   TT3 = SYNCHRONIZE(TT1,TT2) creates the timetable TT3 by synchronizing the
%   timetables TT1 and TT2 to the union of TT1's and TT2's row times. TT3
%   contains the combined set of variables from TT1 and TT2, horizontally
%   concatenated. Duplicate variable names between TT1 and TT2 are made unique.
% 
%   Rows in TT3 whose times match rows in TT1 contain, in the variables
%   corresponding to TT1, a copy of the corresponding data from TT1. The
%   remaining rows of TT3 contain missing data indicators in the variables
%   corresponding to TT1. Similarly, rows in TT3 contain either data from TT2 or
%   missing data indicators.
%
%   If you specify the VariableContinuity property of TT1, TT2, or both,
%   then SYNCHRONIZE fills in or interpolates values in TT3 according to
%   the values specified in VariableContinuity. Using the
%   VariableContinuity property, you can specify whether each timetable
%   variable represents continuous, step, or event data. For each variable,
%   SYNCHRONIZE then uses one of the following methods to fill in or
%   interpolate values:
%
%   VariableContinuity              Default Method
%   ------------------              ---------------
%   unset                           fillwithmissing
%   continuous                      linear
%   step                            previous
%   event                           fillwithmissing
% 
%   TT3 = SYNCHRONIZE(TT1,TT2,NEWTIMEBASIS) synchronizes TT1 and TT2 to a common
%   vector of row times computed from their two vectors of row times as specified
%   by NEWTIMEBASIS. NEWTIMEBASIS is one of the following character vectors:
% 
%      'union'        - the union of the row times (default)
%      'intersection' - the intersection of the row times
%      'commonrange'  - the union of the row times, over the intersection
%                       of the time ranges
%      'first'        - the row times of the first timetable input
%      'last'         - the row times of the last timetable input
%  
%   TT3 = SYNCHRONIZE(TT1,TT2,NEWTIMESTEP) synchronizes TT1 and TT2 to a common
%   time vector that is regularly-spaced by the time unit specified by NEWTIMESTEP,
%   and that spans the range of times in TT1's and TT2's row times. NEWTIMESTEP is
%   'yearly', 'quarterly', 'monthly', 'weekly', 'daily', 'hourly', 'minutely', or
%   'secondly'.
% 
%   TT3 = SYNCHRONIZE(TT1,TT2,NEWTIMES) synchronizes TT1 and TT2 to NEWTIMES, a
%   specified vector of unique, sorted datetimes or durations. The values of
%   NEWTIMES become the row times of TT3.
% 
%   TT3 = SYNCHRONIZE(TT1,TT2,'regular','TimeStep',DT) synchronizes TT1 and TT2
%   to a common time vector that is regularly-spaced with the specified time step
%   DT, and that spans the range of times in TT1's and TT2's row times. DT is a
%   scalar duration or calendarDuration. METHOD specifies how SYNCHRONIZE creates
%   data at TT3's row times, as described below.
% 
%   TT3 = SYNCHRONIZE(TT1,TT2,'regular','SamplingRate',FS) synchronizes TT1 and
%   TT2 to a common time vector that is regularly-spaced with the specified
%   sampling rate FS, and that spans the range of times in TT1's and TT2's row
%   times. FS is a positive scalar numeric value. METHOD specifies how SYNCHRONIZE
%   creates data at TT3's row times, as described below.
% 
%   TT3 = SYNCHRONIZE(TT1,TT2,NEWTIMEBASIS,METHOD),
%   TT3 = SYNCHRONIZE(TT1,TT2,NEWTIMESTEP,METHOD),
%   TT3 = SYNCHRONIZE(TT1,TT2,NEWTIMES,METHOD),
%   TT3 = SYNCHRONIZE(TT1,TT2,'regular',METHOD,TimeStep',DT), or
%   TT3 = SYNCHRONIZE(TT1,TT2,'regular',METHOD,'SamplingRate',FS)
%   create new data for unmatched rows in TT3 by adjusting the data from TT1 and
%   TT2 onto TT3's row times, rather than inserting missing data indicators. METHOD
%   specifies a function used to create the data. For example, when NEWTIMEBASIS
%   is 'last' and METHOD is 'spline', TT3 contains values for TT1's variables that
%   are interpolated onto TT2's row times. 
%
%   If the VariableContinuity property of any input timetable is set, then
%   METHOD overrides the values in VariableContinuity. RETIME applies METHOD
%   to every timetable variable.
%
%   METHOD is a character vector from one of the following categories:
% 
%      Filling methods: fill unmatched rows in TT3 as specified.
%         'fillwithmissing'  - (default) fill with missing data indicators
%         'fillwithconstant' - fill with the value of the 'Constant' parameter
% 
%      Nearest neighbor methods: copy data from TT1 or TT2 into unmatched rows
%      in TT3. TT1 and TT2 must be sorted by time.
%         'previous' - copy data from the nearest preceding neighbor in TT1
%         'next'     - copy data from the nearest following neighbor in TT1
%         'nearest'  - copy data from the nearest neighbor in TT1
% 
%      Interpolation methods: fill unmatched rows in TT3 by interpolating data from
%      neighboring rows in TT1 or TT2. TT1 and TT2 must be sorted by time and contain
%      unique times. To control how the data are extrapolated, use the 'EndValues'
%      parameter.
%         'linear' - use linear interpolation
%         'spline' - use piecewise cubic spline interpolation
%         'pchip'  - use shape-preserving piecewise cubic interpolation
% 
%      Aggregation methods: fill rows in TT3 by aggregating data from TT1 or TT2 over
%      time bins defined by the specified vector of row times. When NEWTIMES is
%      provided, the last row of TT3 consists of only the data that exactly matches
%      the last time value.  SYNCHRONIZE assigns the left edges of the bins as TT3's
%      row times. To control whether the left or right bin edge is included in the
%      time bins, use the 'IncludedEdge' parameter.  The listed methods omit NaNs,
%      NaTs, and other missing data indicators when aggregating data. To include
%      missing data indicators, specify the method as a function handle to a function
%      that includes them when aggregating data.  @fun applies a user-specified
%      function to all data in each bin, including missing values.
%         'count'      - count the number of rows in each bin
%         'sum'        - sum the values in each bin
%         'mean'       - use the mean of values in each bin
%         'prod'       - use the product of values in each bin
%         'min'        - use the maximum value in each bin
%         'max'        - use the minimum value in each bin
%         'firstvalue' - use the first value in each bin
%         'lastvalue'  - use the last value in each bin
%         @fun         - use the specified function
% 
%   METHOD can also be 'default'. This is equivalent to using 'fillwithmissing'
%   for variables whose VariableContinuity property is not set, or using the
%   method corresponding to the VariableContinuity property setting.
% 
%   TT3 = SYNCHRONIZE(..., 'PARAM1',val1, 'PARAM2',val2, ...) allows you to
%   specify optional parameter name/value pairs. Parameters are:
%   
%         'Constant'     - the constant value used with 'fillwithconstant'.
%                          Default is 0.
%         'EndValues'    - the extrapolation method used for 'next', 'previous',
%                          'nearest', 'linear', 'spline', and 'pchip'. Values
%                          are 'extrap' (default) to use METHOD to extrapolate,
%                          or a scalar value to extrapolate with a constant.
%         'IncludedEdge' - specifies which bin edges are included in the time bins
%                          used in the aggregation methods. Values are 'left' (the
%                          default) to include the left bin edges and 'right' to
%                          include the right bin edges. 'IncludedEdge' also controls
%                          which bin edges are returned as TT3's row times.
% 
%   TT = SYNCHRONIZE(TT1,TT2,...,TTN,...),
%   TT = SYNCHRONIZE(TT1,TT2,...,TTN,...),
%   TT = SYNCHRONIZE(TT1,TT2,...,TTN,...), or
%   TT = SYNCHRONIZE(TT1,TT2,...,TTN,...)
%   synchronize the timetables TT1, TT2, ... and TTN to the specified common vector
%   of row times.
% 
%   See also: RETIME, INNERJOIN, OUTERJOIN, HORZCAT, VERTCAT.

%   Copyright 2016-2018 The MathWorks, Inc.

import matlab.internal.datatypes.isScalarText

try %#ok<ALIGN>

% Count the number of timetable inputs, get their workspace names, and make sure they all
% have the same kind of time vector.
timetableInputNames = cell(1,nargin);
ntimetables = 0;
haveDurations = false;
for i = 1:nargin
    if ~isa(varargin{i},'timetable'), break; end
    ntimetables = i;
    timetableInputNames{i} = inputname(i);
    
    if isduration(varargin{i}.rowDim.labels) ~= haveDurations
        if ntimetables > 1
            error(message('MATLAB:timetable:synchronize:MixedTimeTypes'));
        else
            haveDurations = true;
        end
    end
end
timetableInputs = varargin(1:ntimetables);
timetableInputNames = timetableInputNames(1:ntimetables);

endValues = 'extrap';
includedEdge = 'left';
fillConstant = 0;
isAggregation = false;
isMethodProvided = false;
method = 'default';

if ntimetables == 0
    error(message('MATLAB:timetable:synchronize:NonTimetableInput'));
elseif nargin == ntimetables
    % Sync to the union of the time vectors, fill unmatched rows with missing
    [newTimes,timesMinMax] = processNewTimesInput('union',timetableInputs);
    copyFirstLastInput = [false false];
elseif nargin == ntimetables + 1
    % Sync to the specified time vector, fill unmatched rows with missing
    newTimesArg = varargin{ntimetables+1};
    [newTimes,timesMinMax] = processNewTimesInput(newTimesArg,timetableInputs);
    if strcmp(newTimesArg,'regular')
        error(message('MATLAB:timetable:synchronize:RegularWithoutParams'));
    end
    copyFirstLastInput = strcmp(newTimes,{'first' 'last'});
else % nargin >= ntimetables + 2
    % Sync to the specified time vector.
    newTimesArg = varargin{ntimetables+1};
    [newTimes,timesMinMax] = processNewTimesInput(newTimesArg,timetableInputs);
    
    % Sync using the specified method. Call processMethodInput to get errors on the
    % method before errors on the optional inputs.
    methodArg = varargin{ntimetables+2};
    [method,isMethodProvided,isPreservingMethod,isAggregation] = processMethodInput(methodArg);
    if isMethodProvided
        % Found a method, start the name value pairs after that input arg.
        nvPairsStart = 3;
    else
        % If the third input arg was anything other than a name or a function
        % handle, processMethodInput will have errored. Only possibility left is
        % if the third input is the name of _something_, just not a recognized
        % method name. If no other inputs, error as an unrecognized method,
        % otherwise try it as a param name.
        if nargin == (ntimetables + 2)
            error(message('MATLAB:timetable:synchronize:UnrecognizedMethod',methodArg));
        end
        nvPairsStart = 2;
        method = 'default';
    end
    
    if nargin > ntimetables + 2
        pnames = {   'Constant' 'EndValues' 'IncludedEdge'  'SamplingRate'    'TimeStep'};
        dflts =  {fillConstant   endValues   includedEdge              []            [] };
        try
            [fillConstant,endValues,includedEdge,samplingRate,timeStep,supplied] ...
                = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{ntimetables+nvPairsStart:end});
        catch ME
            if isMethodProvided
                % The method was correctly provided, must be a param error, just rethrow.
                rethrow(ME);
            else
                % At this point, the first of the varargins passed to parseArgs
                % must be a name, but not a method name. All that's left is to
                % decide to flag a bad method name or bad params.
                if strcmp(ME.identifier,'MATLAB:table:parseArgs:WrongNumberArgs')
                    % An odd number of varargins, assume the first was a bad method name.
                    error(message('MATLAB:timetable:synchronize:UnrecognizedMethod',methodArg));
                else
                    % An even number of varargins, assume all params.
                    rethrow(ME);
                end
            end
        end
        
        % Constant has to be a scalar, and EndValues has to be either 'extrap' or a
        % scalar. These scalar values are otherwise validated by assignment in retime.
        % IncludedEdge must be 'left' or 'right'.
        if ~isscalar(fillConstant)
            error(message('MATLAB:timetable:synchronize:InvalidConstant'));
        end
        if ~isscalar(endValues) && ~strcmp(endValues,'extrap')
            error(message('MATLAB:timetable:synchronize:InvalidEndValues'));
        end
        try
            includedEdge = validatestring(includedEdge,{'left','right'});
        catch
            error(message('MATLAB:timetable:synchronize:InvalidIncludedEdge'));
        end
    elseif strcmp(newTimesArg,'regular')
        error(message('MATLAB:timetable:synchronize:RegularWithoutParams'));
    end
    
    if strcmp(newTimesArg,'regular')
        % Parameters have been processed, compute the target time vector using a
        % time step or a sampling rate.
        [newTimes,timesMinMax] = processRegularNewTimesInput(supplied,timeStep,samplingRate,timetableInputs);
    end
    
    copyFirstLastInput = strcmp(varargin{ntimetables+1},{'first' 'last'}) & isPreservingMethod;
end

if ~(haveDurations == isduration(newTimes))
    error(message('MATLAB:timetable:synchronize:MixedTimeTypesNewTimes'));
end

% Unlike horzcat, but like inner/outerjoin, synchronize will allow duplicate var
% names in the two inputs, and make them unique.
if ntimetables > 1
    timetableInputs = uniqueifyVarNames(timetableInputs,timetableInputNames);
end

% Call retimeIt to do the actual work. If syncing to the fist input, and the
% method is one that just copies data for matching times, there's no need to
% call retimeIt on the first input, just copy it.
overrideVarContinuity = isMethodProvided && ~strcmp(method,'default');
for i = (1+copyFirstLastInput(1)):(ntimetables-copyFirstLastInput(2))
    if overrideVarContinuity || isempty(timetableInputs{i}.Properties.VariableContinuity)
        [newTimesOut,newData] = retimeIt(timetableInputs{i},newTimes,method,isAggregation,endValues,includedEdge,fillConstant,timesMinMax);
    else
        % If VariableContinuity property is not empty and a method was not
        % provided to override that, apply the method corresponding to each
        % variable's VariableContinuity, and merge the results.
        continuityVals = enumeration('matlab.tabular.Continuity');
        newData = cell(1,timetableInputs{i}.varDim.length);
        for j = continuityVals(:)' % need row vector in the for-loop index
            whichVars = (timetableInputs{i}.varDim.continuity == j);
            % Only retimeIt if there are variables to work on with that method.
            if nnz(whichVars)
                ttSubset = timetableInputs{i}.subsrefParens({':',whichVars});
                interpMethod = j.InterpolationMethod;
                [newTimesOut,newDataOut] = retimeIt(ttSubset,newTimes,interpMethod,isAggregation,endValues,includedEdge,fillConstant,timesMinMax);
                % Build up new combined .data
                newData(whichVars) = newDataOut;
            end
        end
    end
    % Get the varDim and metaDim from the original timetable to patch up the new timetable.
    tt2 = timetable.init(newData, length(newTimesOut), newTimesOut, timetableInputs{i}.varDim.length,timetableInputs{i}.varDim.labels);
    tt2.varDim = timetableInputs{i}.varDim;
    tt2.metaDim = timetableInputs{i}.metaDim;
    timetableInputs{i} = tt2;
end
ttOut = [timetableInputs{:}];

catch ME, throw(ME); end % keep the stack trace to one level


%-------------------------------------------------------------------------------
function [method,isRecognized,isPreserving,isAggregation] = processMethodInput(method)
% Validate the method input, and classify it according to whether it preserves
% the original data if evaluated at the original times 
import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isCharStrings
isRecognized = true;
if isCharString(method)
    method = lower(method);
    switch method
    case {'previous' 'next' 'nearest' 'linear' 'spline' 'pchip' 'fillwithmissing' 'fillwithconstant'}
        % When evaluated at times that are in an input's time vector, these
        % methods simply repeat that input's data, untouched. So if the target
        % is one of the inputs' time vectors, that input need not be worked on.
        isPreserving = true;
        isAggregation = false;
    case {'count' 'sum' 'mean' 'prod' 'min' 'max' 'firstvalue' 'lastvalue'}
        % These methods (potentially) modify data even when evaluated at times
        % that are in an input's original time vector. So even if the target is
        % one of the inputs' time vectors, calculation must still be done on
        % that input.
        isPreserving = false;
        isAggregation = true;
    case 'default'
        isPreserving = false;
        isAggregation = false;
    otherwise
        % The argument was a name but not a method name.
        isRecognized = false;
        isPreserving = false;
        isAggregation = false;
    end
elseif isa(method,'function_handle')
    isPreserving = false;
    isAggregation = true;
else
    % The argument was not a method name or a function handle.
    error(message('MATLAB:timetable:synchronize:InvalidMethod'));
end

%-------------------------------------------------------------------------------
function [newTimes,timesMinMax] = processNewTimesInput(newTimes,timetableInputs)
% Validate the newTimeBasis, newTimeStep, or newTimes input, and compute the
% actual time vector for newTimeBasis or newTimeStep
import matlab.internal.datatypes.isCharString

ntimetables = length(timetableInputs);
timesMinMax = [];

if isdatetime(newTimes) || isduration(newTimes)
    requireMonotonic(newTimes,'',true); % require strictly monotonic and non-missing in target
elseif isCharString(newTimes)
    switch lower(newTimes)
    case 'union'
        newTimes = sort(timetableInputs{1}.rowDim.labels);
        for i = 2:ntimetables
            newTimes = union(newTimes,timetableInputs{i}.rowDim.labels,'sorted');
        end
        requireNonMissing(newTimes,''); % target already monotonic, require non-missing
    case 'intersection'
        newTimes = sort(timetableInputs{1}.rowDim.labels);
        for i = 2:ntimetables
            newTimes = intersect(newTimes,timetableInputs{i}.rowDim.labels,'sorted');
        end
        requireNonMissing(newTimes,''); % target already monotonic, require non-missing
    case 'commonrange'
        [tmin,tmax] = getCommonTimeRange(timetableInputs,'intersection');
        newTimes = timetableInputs{1}.rowDim.labels([]);
        for i = 1:ntimetables
            times = timetableInputs{i}.rowDim.labels;
            times = times(tmin <= times & times <= tmax);
            newTimes = union(newTimes,times,'sorted');
        end
        requireNonMissing(newTimes,''); % target already monotonic, require non-missing
    case 'first'
        newTimes = timetableInputs{1}.rowDim.labels;
        requireMonotonic(newTimes,'',true); % require strictly monotonic and non-missing in target
    case 'last'
        newTimes = timetableInputs{end}.rowDim.labels;
        requireMonotonic(newTimes,'',true); % require strictly monotonic and non-missing in target
    case 'regular'
        % processRegularNewTimesInput will handle this case
    otherwise 
        newTimeStep = newTimes;
        [tmin,tmax] = getCommonTimeRange(timetableInputs,'union');

        % For aggregation with a newTimeStep ('hourly', 'minutely', ...), we'll need the min
        % and max bin edges in retimeIt for dealing with deciding whether there are any times
        % that exactly match the first/last bin edge (which one depends on IncludedEdge) and
        % therefore whether there should be a degenerate bin.
        timesMinMax = [tmin tmax];
        
        [tleft,tright,newTimeStep] = getSpanningTimeLimits(tmin,tmax,newTimeStep);
        newTimes = (tleft:newTimeStep:tright)'; % no round-off issues at seconds or greater resolution
        requireNonMissing(newTimes,''); % target already monotonic, require non-missing
    end
else
    error(message('MATLAB:timetable:synchronize:InvalidNewTimes'));
end

newTimes = newTimes(:); % force everything to a column

%-------------------------------------------------------------------------------
function [newTimes,timesMinMax] = processRegularNewTimesInput(supplied,timeStep,samplingRate,timetableInputs)
% Validate the TimeStep or SamplingRate parameter and values, and compute the corresponding
% regular time vector
import matlab.internal.tabular.validateTimeVectorParams

[tmin,tmax] = getCommonTimeRange(timetableInputs,'union');
timesMinMax = [tmin tmax];

supplied.RowTimes = false;
supplied.StartTime = true;
[rowTimesDefined,~,~,timeStep,samplingRate] = validateTimeVectorParams(supplied,[],tmin,timeStep,samplingRate);
if ~rowTimesDefined
    error(message('MATLAB:timetable:synchronize:RegularWithoutParams'));
end
if supplied.TimeStep
    % Find limits to span the data, nicely aligned w.r.t. the time step
    [unit,timeStep] = getRegularTimeVectorAlignment(timeStep);
    [tleft,~] = getSpanningTimeLimits(tmin,tmax,unit);

    % Calculate the number of rows for the time vector
    if isa(timeStep,'duration')
        % For a duration time step, start newTimes at the nicely aligned origin
        % from getSpanningTimeLimits plus a whole multiple of the time step
        dt = seconds(timeStep);
        tleft = tleft + seconds(floor(seconds(tmin-tleft)/dt)*dt);
        numRows = ceil((tmax - tleft)/timeStep) + 1;
        newTimes = matlab.internal.tabular.private.rowTimesDim.regularRowTimesFromTimeStep(tleft,timeStep,numRows);
    else
        newTimes = matlab.internal.tabular.private.rowTimesDim.regularRowTimesFromCalDurTimeStep(tleft,timeStep,tmax);
        if newTimes(end) < tmax
            newTimes(end+1) = newTimes(end) + timeStep;
        end
    end
else % supplied.SamplingRate
    % Start newTimes on a whole second plus a whole multiple of the time step
    [tleft,~] = getSpanningTimeLimits(tmin,tmax,'secondly');
    tleft = tleft + seconds(floor(seconds(tmin-tleft)*samplingRate)/samplingRate);
    numRows = ceil(seconds(tmax - tleft)*samplingRate) + 1;
    newTimes = matlab.internal.tabular.private.rowTimesDim.regularRowTimesFromSamplingRate(tleft,samplingRate,numRows);
end

%-------------------------------------------------------------------------------
function [tleft,tright,timeStep] = getSpanningTimeLimits(tmin,tmax,timeStep)
% Given a choice of time step name and the min/max times of the data being synchronized,
% return nicely-aligned spanning time limits and the actual time step.
if isdatetime(tmin)
    switch lower(timeStep)
    case 'secondly',  timeStepName = 'second';  timeStep = seconds(1);
    case 'minutely',  timeStepName = 'minute';  timeStep = minutes(1);
    case 'hourly',    timeStepName = 'hour';    timeStep = hours(1);
    case 'daily',     timeStepName = 'day';     timeStep = caldays(1);
    case 'weekly',    timeStepName = 'week';    timeStep = calweeks(1);
    case 'monthly',   timeStepName = 'month';   timeStep = calmonths(1);
    case 'quarterly', timeStepName = 'quarter'; timeStep = calquarters(1);
    case 'yearly',    timeStepName = 'year';    timeStep = calyears(1);
    otherwise
        error(message('MATLAB:timetable:synchronize:UnknownNewTimeStep',timeStep));
    end
    % Choose newTimes to span the row times of the inputs, as the floor/ceil of
    % tmin/tmax w.r.t the specified unit, equal to tmin/tmax if that falls on a
    % whole unit.
    tleft = dateshift(tmin,'start',timeStepName); % floor
    tright = dateshift(tmax,'start',timeStepName); % first step in ceil
    if (tright < tmax)
        tright = tright + timeStep; % second step in ceil
    end
else
    switch lower(timeStep)
    case 'secondly',  timeStepName = 'seconds';  timeStep = seconds(1);
    case 'minutely',  timeStepName = 'minutes';  timeStep = minutes(1);
    case 'hourly',    timeStepName = 'hours';    timeStep = hours(1);
    case 'daily',     timeStepName = 'days';     timeStep = days(1);
    case 'yearly',    timeStepName = 'years';    timeStep = years(1);
    case {'weekly' 'monthly' 'quarterly'}
        error(message('MATLAB:timetable:synchronize:UnknownNewTimeStepDuration',timeStep));
    otherwise
        error(message('MATLAB:timetable:synchronize:UnknownNewTimeStep',timeStep));
    end
    % Choose newTimes to span the row times of the inputs. See comments above.
    tleft = floor(tmin,timeStepName);
    tright = ceil(tmax,timeStepName);
end


%-------------------------------------------------------------------------------
function [unit,timeStep] = getRegularTimeVectorAlignment(timeStep)
% Given a time step, return the time unit or calendar unit at which to align the
% "origin" for a regular time vector (the actual time vector will be offset by a
% multiple of the time step from that alignment). The time step is required to
% be positive. A calendarDuration time step is assumed to be "pure". If it is
% "pure time" it's transformed into a duration.
if isa(timeStep,'duration')
    dt = milliseconds(timeStep);
    if dt <= 0
        error(message('MATLAB:timetable:synchronize:NonPositiveTimeStep'));
    elseif dt <= 1000       %     0 < step <= 1 sec => secondly alignment
        unit = 'secondly';
    elseif dt <= 60*1000    % 1 sec < step <= 1 min => minutely alignment
        unit = 'minutely';
    elseif dt <= 60*60*1000 % 1 min < step <= 1 hr  => hourly alignment
        unit = 'hourly';
    else                    % 1 hr  < step          => daily alignment
        unit = 'daily';
    end
else
    [m,d,t] = split(timeStep,{'months' 'days' 'time'});
    if m > 0
        % For a pure months TimeStep, align the new row times to months, even if
        % TimeStep is a whole number of quarters or years
        unit = 'monthly';
    elseif d > 0
        % For a pure days TimeStep, align the new row times to days, even if
        % TimeStep is a whole number of weeks
        unit = 'daily';
    elseif t > 0
        % timeStep is a calendarDuration containing only time, treat as a duration
        timeStep = time(timeStep);
        unit = getRegularTimeVectorAlignment(timeStep);
    else
        % Assuming the calendarDuration is pure, then its one non-zero component
        % must have been non-positive.
        error(message('MATLAB:timetable:synchronize:NonPositiveTimeStep'));
    end
end

%-------------------------------------------------------------------------------
function [tmin,tmax] = getCommonTimeRange(timetableInputs,rangeType)
% Find the common time range of the timetable's tme vectors

% Get min/max times for each timetable - some may be empty and need to be
% propagated along so the 'all-empty' case flows through properly.
ntimetables = length(timetableInputs);
tmin = cell(1,ntimetables);
tmax = tmin;
for i = 1:ntimetables
    times = timetableInputs{i}.rowDim.labels;
    tmin{i} = min(times);
    tmax{i} = max(times);
end

% Expand and concatenate tmin/tmax. Empties will be ignored if at least one
% of the 'tmin/tmax's is non-empty; if all of tmin/tmax is empty, vertcat
% (correctly) returns empty to proprogate it along.
% vertcat: rowTimes are always column
tmin = vertcat(tmin{:});
tmax = vertcat(tmax{:});

switch rangeType
case 'union' % the union of the ranges
    tmin = min(tmin);
    tmax = max(tmax);
case 'intersection' % the intersection of the ranges
    tmin = max(tmin);
    tmax = min(tmax);
otherwise
    assert(false);
end


%-------------------------------------------------------------------------------
function timetableInputs = uniqueifyVarNames(timetableInputs,timetableInputNames)
% Make unique any variable names that are duplicated across the timetables

% Get the var names in, and the workspace name of, each input timetable
nTimetables = length(timetableInputs);
varNames = cell(1,nTimetables);
nVarNames = zeros(1,nTimetables);
for i = 1:nTimetables
    varNames{i} = timetableInputs{i}.varDim.labels;
    nVarNames(i) = timetableInputs{i}.varDim.length;
    if isempty(timetableInputNames{i})
        timetableInputNames{i} = num2str(i,'%-d'); % no input name, just add a unique number
    end
end

% Combine all the names, check for duplicates across timetables. The names are
% already known to be unique within each timetable
allVarNames = [varNames{:}];
[uniqueVarNames,firstOccurrences] = unique(allVarNames,'stable');
if length(uniqueVarNames) < length(allVarNames)
    % Find all the duplicated var names. Don't care what is a duplicate of what,
    % adding a suffix that's specific to each input will make them all unique
    duplicatedOccurrences = 1:length(allVarNames); duplicatedOccurrences(firstOccurrences) = [];
    repeatedNames = unique(allVarNames(duplicatedOccurrences));
    needsUniqueifying = ismember(allVarNames,repeatedNames); 
    % Uniqueify the duplicate var names by adding the timetable's workspace name as
    % a suffix
    all2which = repelem(1:nTimetables,nVarNames);
    allVarNames(needsUniqueifying) = strcat(allVarNames(needsUniqueifying),'_',timetableInputNames(all2which(needsUniqueifying)));
    % Don't allow the uniqueified names on either side to duplicate existing
    % names from either side
    allVarNames = matlab.lang.makeUniqueStrings(allVarNames,needsUniqueifying,namelengthmax);
    
    % Put the unique names back into the timetables
    varNames = mat2cell(allVarNames,1,nVarNames);
    for i = 1:nTimetables
        timetableInputs{i}.varDim = timetableInputs{i}.varDim.setLabels(varNames{i});
    end
end


%-------------------------------------------------------------------------------
function [newTimes,newData] = retimeIt(tt1,newTimes,method,isAggregation,endValues,includedEdge,fillConstant,timesMinMax)
% Synchronize one timetable to a new time vector using the specified method
tt1_data = tt1.data;

if isa(method,'function_handle') % allow the switch to control this case
    fun = method;
    method = 'fun';
end

if ~isAggregation && tt1.rowDim.length < 2 && ~strcmp(method,'fillwithconstant')
    % interp1 requires two data points. Except for 'fillWithConstant', the correct
    % result for zero or one is identical to the 'fillWithMissing' behavior, so use
    % that regardless of what the actual (non-aggregation) method was.
    method = 'fillwithmissing';
end
    
switch method
case {'default' 'fillwithmissing'}
    requireMissingAware(tt1,method);
    [i2,locs] = ismember(newTimes,tt1.rowDim.labels); % select the first among dups
    i1 = locs(locs>0);
    tt2_data = cell(1,length(tt1_data));
    for j = 1:length(tt2_data)
        var_j = tt1_data{j};
        sz = size(var_j); sz(1) = length(newTimes);
        tt2_data{j} = matlab.internal.datatypes.defaultarrayLike(sz,'like',var_j);
        tt2_data{j}(i2,:) = var_j(i1,:);
    end

case 'fillwithconstant'
    [i2,locs] = ismember(newTimes,tt1.rowDim.labels); % select the first among dups
    i1 = locs(locs>0);
    tt2_data = cell(1,length(tt1_data));
    for j = 1:length(tt2_data)
        var_j = tt1_data{j};
        sz = size(var_j); sz(1) = length(newTimes);
        tt2_data{j} = matlab.internal.datatypes.defaultarrayLike(sz,'like',var_j);
        tt2_data{j}(i2,:) = var_j(i1,:);
        tt2_data{j}(~i2,:) = fillConstant;
    end

case {'previous' 'next' 'nearest'}
    requireMonotonic(tt1.rowDim.labels,method,false); % don't require strictly monotonic
    % interp1 only works on numeric and datetime/duration. To support nearest
    % neighbor interpolation on other types, interpolate on the indices of the
    % data rather than on the data themselves. The actual data will be copied
    % from input to output based on which indices are selected.
    %
    % interp1 also does not allow repeated grid points. To support nearest neighbor
    % interpolation even when there are repeated row times, use the unique times and
    % let interp1 interpolate their indices, returning the appropriate member from
    % each group of repeats.

    % For 'extrap', rely on interp1 to do next/prev/nearest extrapolation on the
    % indices (or return NaN where it can't), otherwise tell it to just flag the
    % locations where it would have to extrapolate.
    defaultExtrap = strcmp(endValues,'extrap');
    if defaultExtrap
        extrap = 'extrap';
    else
        extrap = NaN;
    end

    % Initialize cache to hold interpolated indices when there is no missing data
    locsNoMissingCache = [];
    
    tt1_time = tt1.rowDim.labels;
    tt2_data = cell(1,length(tt1_data));
    for j = 1:length(tt2_data)
        t = tt1_time;
        var_j = tt1_data{j};
        try
            missingMask = any(ismissing(matlab.internal.datatypes.matricize(var_j)),2);
        catch % default to no missing data if ISMISSING errors
            missingMask = false(size(var_j,1),1);
        end
        
        % Carry out fresh interpolation if this variable contains missing values, or 
        % if indices cache is empty, otherwise directly use the cached indices
        isLocsCacheEmpty = isempty(locsNoMissingCache);
        hasMissing = any(missingMask);
        if isLocsCacheEmpty || hasMissing
            % Always ignore times and data corresponded to missing data for interpolation
            if hasMissing
                t = t(~missingMask);
                var_j = var_j(~missingMask,:);
            end
            
            if strcmp(method,'previous')
                % Interpolate to find the index of the previous grid point for each query point.
                % In each group of repeated grid points, get the last one, to make 'previous'
                % continuous from the right.
                [ut,iut] = unique(t,'last');
                locs = interp1(ut,iut,newTimes,method,extrap);
            elseif strcmp(method,'next')
                % Interpolate to find the index of the next grid point for each query point.
                % In each group of repeated grid points, get the first one, to make 'next'
                % continuous from the left.
                [ut,iut] = unique(t,'first');
                locs = interp1(ut,iut,newTimes,method,extrap);
            else
                % Find the first in each group of duplicate grid points.
                [ut,itFirst] = unique(t,'first');
                % Find the last in each group of duplicate grid points.
                [~,itLast] = unique(t,'last');
                % Find the index of the nearest unique grid point for each query point.
                iut = interp1(ut,1:length(ut),newTimes,method,extrap);
                if defaultExtrap
                    % For 'extrap', interp1 using 'nearest' returns valid indices everywhere in iut.
                    nearestUt = ut(iut);
                else
                    % Otherwise, interp1 returns NaNs in iut to indicate extrapolation, set
                    % things up so that locs is also NaN in those elements.
                    nearestUt = matlab.internal.datatypes.defaultarrayLike(size(iut),'like',ut);
                    idxNonNaN = ~isnan(iut);
                    nearestUt(idxNonNaN) = ut(iut(idxNonNaN));
                end
                % Return the first in each group of duplicate grid points for query points that
                % are smaller than their nearest grid point, and the last in each group of
                % duplicate grid points for query points that are larger than their nearest grid
                % point.
                locs = nan(size(newTimes));
                useFirst = (newTimes <= nearestUt);
                locs(useFirst) = itFirst(iut(useFirst));
                useLast = (newTimes > nearestUt);
                locs(useLast) = itLast(iut(useLast));
            end
            
            % If there was no missing row in this variable, locs are the interpolated
            % location including the whole time vector. Cache result for performance.
            if isLocsCacheEmpty && ~hasMissing
                locsNoMissingCache = locs;
            end
        else % No missing - use cached locs interpolated from full time vector for this variable
            locs = locsNoMissingCache;
        end
        
        % Using 'extrap' told interp1 to use 'next'/'prev'/'nearest' for extrapolation,
        % and interp1 returns NaNs for extrapolation to the left with 'prev', and to the
        % right for 'next'. Anywhere loc is non-NaN is where real data goes, anywhere
        % else is left as a missing value from defaultarrayLike. If endValues was
        % specified as a value, interp1 used NaN for _all_ extrapolation, so anywhere
        % loc is NaN is where the specified endValue has to go.
        targetLocs = isfinite(locs);
        sourceLocs = locs(targetLocs);        
        sz = size(var_j); sz(1) = length(newTimes);
        tt2_data{j} = matlab.internal.datatypes.defaultarrayLike(sz,'like',var_j);
        tt2_data{j}(targetLocs,:) = var_j(sourceLocs,:);
        if ~defaultExtrap
            tt2_data{j}(~targetLocs,:) = endValues;
        end
    end

case {'linear' 'spline' 'pchip'}
    requireNumeric(tt1,method,1);
    requireMonotonic(tt1.rowDim.labels,method,true); % require strictly monotonic
    t = tt1.rowDim.labels;
    tt2_data = cell(1,length(tt1_data));
    for j = 1:length(tt2_data)
        tt1_data_matricized = matlab.internal.datatypes.matricize(tt1_data{j});
        missingMask = any(ismissing(tt1_data_matricized),2); % requireNumeric() above guaranteeds ismissing() will not error here
        sz = size(tt1_data{j}); % size of original data        
        sz(1) = sum(~missingMask); % discount from sz rows with missing data
        nonMissingData = reshape(tt1_data_matricized(~missingMask,:),sz); % subset out non-missing data and restore original shape
        tt2_data{j} = interp1(t(~missingMask),nonMissingData,newTimes,method,endValues); % interpolate on non-missing data only
    end

case {'count' 'sum' 'mean' 'prod' 'min' 'max' 'firstvalue' 'lastvalue' 'fun'}
    % For aggregation, get the name of a user-supplied function, or the actual
    % function corresponding to a method name, depending on what's still needed.
    isUserFun = strcmp(method,'fun');
    if isUserFun
        method = func2str(fun);
    else
        fun = str2funcLocal(tt1,method);
    end
    
    % The target time vector has already been checked for monotonicity, but
    % aggregation requires increasing time.
    if (length(newTimes) > 1) && (newTimes(1) > newTimes(2))
        error(message('MATLAB:timetable:synchronize:DecreasingNewTimesForAggregation',method));
    end
    
    ngroups = length(newTimes)-1;
    if ngroups >= 1
        groupIdx = discretize(tt1.rowDim.labels,newTimes,'IncludedEdge',includedEdge);
        % Patch up discretize groups to add the degenerate bin to the end of the output
        % timetable. The degenerate bin only includes data from the input times that are an
        % exact match.  There is no degenerate bin if using 'minutely', etc. and the last bin
        % spans the data. If the time vector is manually specified, that last degenearate bin
        % will be filled with missing values if there are no exact time matches.
        if strcmp(includedEdge,'left')
            if ~isempty(timesMinMax) && timesMinMax(end) < newTimes(end) % doing 'minutely'... and max time isn't on the bin edge.
                % For aggregation using a newTimeStep (determined by timesMinMax being non-empty),
                % one of the bin edges has to be at the next/prev whole unit beyond tmax/tmin of the
                % input time vectors (which one depends on IncludedEdge).
                % If tmax falls between whole units, the ceil is already at the next whole unit, so
                % dispose of the extra bin.
                newTimes = newTimes(1:end-1);
            else
                % Assign a group index to the degenerate bin either if:
                % 1) the newTimes come from a time vector or time basis (e.g. 'union'), or
                % 2) the newTimes come from a time step (e.g. 'hourly') and the tmax matches the last
                %    bin edge in newTimes, then keep it as a degenerate bin.
                ngroups = ngroups + 1;
                groupIdx(tt1.rowDim.labels == newTimes(end)) = ngroups;
            end
        else % strcmp(includedEdge, 'right')
            if ~isempty(timesMinMax) && timesMinMax(1) > newTimes(1) % doing 'minutely'... and min time isn't on the bin edge.
                % dispose of extra bin.
                newTimes = newTimes(2:end);
            else % assign groupIdx to degenerate bin
                ngroups = ngroups + 1;
                groupIdx(tt1.rowDim.labels == newTimes(1)) = 0;
                % groupIdx must cannot include 0 for indexing.
                groupIdx = groupIdx + 1;
            end
        end
    else % For a scalar newTimes, use logical indexing rather than discretize.
        groupIdx = nan(size(tt1.rowDim.labels));
        if ~isempty(newTimes) % no degenerate bin for empty output timetable case
            % create a group and assign it to the rows where the times match the (scalar)
            % newTimes.
            ngroups = 1;
            groupIdx(tt1.rowDim.labels == newTimes) = 1;
        end
    end

    tt2_data = groupedApply(groupIdx,ngroups,tt1_data,tt1.varDim.labels,fun,method,isUserFun);
    
otherwise
    assert(false);
end
newData = tt2_data;


%-------------------------------------------------------------------------------
function b_data = groupedApply(groupIdx,ngroups,a_data,a_varnames,fun,funName,isUserFun)
% Apply a function to each variable by group. Similar to the grouped, table
% output case in varfun, but here the output includes rows for groups that are
% not present in the data, so the function should be prepared to accept a
% possibly empty input.
import matlab.internal.datatypes.ordinalString

grprows = matlab.internal.datatypes.getGroups(groupIdx,ngroups);

ndataVars = length(a_data);

% Each cell will contain the result from applying FUN to one variable,
% an ngroups-by-.. array with one row for each group's result
b_data = cell(1,ndataVars);

% Each cell will contain the result from applying FUN to one group
% within the current variable
outVals = cell(ngroups,1);

for jvar = 1:ndataVars
    var_j = a_data{jvar};
    varname_j = a_varnames{jvar};
    for igrp = 1:ngroups
        inArg = getVarRows(var_j,grprows{igrp});
        try
            outVal = fun(inArg);
        catch ME
            m = message('MATLAB:table:varfun:FunFailedGrouped',funName,ordinalString(igrp),varname_j,ME.message);
            throw(MException(m.Identifier,'%s',getString(m)));
        end
        if size(outVal,1) ~= 1
            error(message('MATLAB:timetable:synchronize:FunMustReturnOneRow',funName));
        end
        outVals{igrp} = outVal;
    end
    
    % vertcat the results from the current var, checking that each group has the
    % same number of rows as it did in the other vars
    if ngroups > 0
        try
            b_data{jvar} = vertcat(outVals{:});
        catch ME
            error(message('MATLAB:table:varfun:VertcatFailed',funName,varname_j,ME.message));
        end
    else
        % If there are no groups, there may be three situations: 
        % 1) 'Count' returns empty doubles, the width of the input variable. 
        % 2) It's a canned function other than 'count', so we know it should returns empties
        %    the same type and size as the input variables.
        % 3) The user function has not been applied to anything, so no way to know what type
        %    and size fun would return. Default to empty double of the same width as the input var.
        sz = size(a_data{jvar});
        sz(1) = 0; % 0 rows, but can otherwise be N-D.
        if strcmp(funName, 'count') || isUserFun % (1) and (3)
            b_data{jvar} = zeros(sz);
        else % (2)
            b_data{jvar} = matlab.internal.datatypes.defaultarrayLike(sz,'like',a_data{jvar});
        end
    end
end


%-------------------------------------------------------------------------------
function var_ij = getVarRows(var_j,i)
% Extract rows of a variable, regardless of its dimensionality
if ismatrix(var_j)
    var_ij = var_j(i,:); % without using reshape, may not have one
else
    % Each var could have any number of dims, no way of knowing,
    % except how many rows they have.  So just treat them as 2D to get
    % the necessary rows, and then reshape to their original dims.
    sizeOut = size(var_j); sizeOut(1) = numel(i);
    var_ij = reshape(var_j(i,:), sizeOut);
end


%-------------------------------------------------------------------------------
function fun = str2funcLocal(tt,method)
% Convert a method input argument into a function handle, with some pre-checks
% on the data it will be applied to
switch method
case 'count'
    fun = @countLocal;
case 'mean'
    requireNumeric(tt,method,1);
    fun = @meanLocal;
case 'sum'
    requireNumeric(tt,method,2);
    fun = @sumLocal;
case 'prod'
    requireNumeric(tt,method,3);
    fun = @prodLocal;
case 'min'
    requireNumeric(tt,method,0);
    fun = @minLocal;
case 'max'
    requireNumeric(tt,method,0);
    fun = @maxLocal;
case 'firstvalue'
    requireMonotonic(tt.rowDim.labels,method,false); % don't require strictly monotonic
    fun = @firstvalueLocal;
case 'lastvalue'
    requireMonotonic(tt.rowDim.labels,method,false); % don't require strictly monotonic
    fun = @lastvalueLocal;
otherwise
    % No checks on the variables for a user-supplied function, it may error
    fun = str2func(method);
end


%-------------------------------------------------------------------------------
function requireNonMissing(times,method)
% Require all variables to be monotonically increasing or decreasing
if any(ismissing(times))
    isTargetTimes = isempty(method);
    if isTargetTimes
        error(message('MATLAB:timetable:synchronize:NotMonotonicNewTimes'));
    else
        error(message('MATLAB:timetable:synchronize:NotMonotonic',method));
    end
end


%-------------------------------------------------------------------------------
function requireMonotonic(times,method,strict)
% Require all variables to be monotonically increasing or decreasing
diffTimes = diff(times);
if strict
    tf = all(diffTimes > 0) || all(diffTimes < 0);
else
    tf = all(diffTimes >= 0) || all(diffTimes <= 0);
end
if ~tf
    isTargetTimes = isempty(method);
    if any(diffTimes == 0)
        if isTargetTimes
            error(message('MATLAB:timetable:synchronize:NotUniqueNewTimes'));
        else
            error(message('MATLAB:timetable:synchronize:NotUnique',method));
        end
    else
        if isTargetTimes
            error(message('MATLAB:timetable:synchronize:NotMonotonicNewTimes'));
        else
            error(message('MATLAB:timetable:synchronize:NotMonotonic',method));
        end
    end
end


%-------------------------------------------------------------------------------
function requireNumeric(tt,method,strictness)
% Require all variables to be numeric-like to some degree
switch strictness
case 0
    % Require all variables to be "numeric-like" in the sense that they are ordered, so
    % support min/max/mode/median
    isNumericIsh = @(x) isnumeric(x) || isdatetime(x) || isduration(x) || (iscategorical(x) && isordinal(x));
    which = cellfun(isNumericIsh,tt.data);
    if nargout == 0 && ~all(which)
        error(message('MATLAB:timetable:synchronize:NotNumeric0',method));
    end
case 1
    % Require all variables to be "numeric-like", and have mean/min/max methods as
    % well as support interpolation
    isNumericIsh = @(x) isnumeric(x) || isdatetime(x) || isduration(x);
    which = cellfun(isNumericIsh,tt.data);
    if nargout == 0 && ~all(which)
        error(message('MATLAB:timetable:synchronize:NotNumeric1',method));
    end
case 2
    % Require all variables to be even more "numeric-like", and have a sum
    % method as well
    isNumericIsh = @(x) isnumeric(x) || isduration(x);
    which = cellfun(isNumericIsh,tt.data);
    if nargout == 0 && ~all(which)
        error(message('MATLAB:timetable:synchronize:NotNumeric2',method));
    end
case 3
    % Require all variables to be strictly numeric
    which = cellfun(@isnumeric,tt.data);
    if nargout == 0 && ~all(which)
        error(message('MATLAB:timetable:synchronize:NotNumeric3',method));
    end
otherwise
    assert(false);
end


%-------------------------------------------------------------------------------
function requireMissingAware(tt,method)
% Require all variables to have some standard way to represent missing values
import matlab.internal.datatypes.isCharStrings
isMissingAware = @(x) isfloat(x) ...
                   || iscategorical(x) ...
                   || isdatetime(x) || isduration(x) || iscalendarduration(x) ...
                   || isCharStrings(x,true) || isstring(x) || (ischar(x) && ismatrix(x));
which = cellfun(isMissingAware,tt.data);
if nargout == 0 && ~all(which)
    error(message('MATLAB:timetable:synchronize:NotMissingAware',method));
end


%-------------------------------------------------------------------------------
% "Canned" methods that omit missing values automatically
function y = countLocal(x)
hasValue = ~any(ismissing(matlab.internal.datatypes.matricize(x)),2);
x = x(hasValue,:);
y = size(x,1);
%-------------------------------------------------------------------------------
function y = sumLocal(x)
y = sum(x,1,'omitnan');
%-------------------------------------------------------------------------------
function y = prodLocal(x)
y = prod(x,1,'omitnan');
%-------------------------------------------------------------------------------
function y = meanLocal(x)
y = mean(x,1,'omitnan');
%-------------------------------------------------------------------------------
function y = minLocal(x)
if size(x,1) > 0
    if iscategorical(x) && isordinal(x)
        y = min(x,[],1);
    else
        y = min(x,[],1,'omitnan');
    end
else
    sz = size(x); sz(1) = 1;
    y = matlab.internal.datatypes.defaultarrayLike(sz,'like',x);
end
%-------------------------------------------------------------------------------
function y = maxLocal(x)
if size(x,1) > 0
    if iscategorical(x) && isordinal(x)
        y = max(x,[],1);
    else
        y = max(x,[],1,'omitnan');
    end
else
    sz = size(x); sz(1) = 1;
    y = matlab.internal.datatypes.defaultarrayLike(sz,'like',x);
end
%-------------------------------------------------------------------------------
function y = firstvalueLocal(x)
sz = size(x); sz(1) = 1;
x = matlab.internal.datatypes.matricize(x);
hasValue = ~any(ismissing(x),2);
x = x(hasValue,:);
if size(x,1) > 0
    y = reshape(x(1,:),sz);
else
    y = matlab.internal.datatypes.defaultarrayLike(sz,'like',x);
end
%-------------------------------------------------------------------------------
function y = lastvalueLocal(x)
sz = size(x); sz(1) = 1;
x = matlab.internal.datatypes.matricize(x);
hasValue = ~any(ismissing(x),2);
x = x(hasValue,:);
if size(x,1) > 0
    y = reshape(x(end,:),sz);
else
    y = matlab.internal.datatypes.defaultarrayLike(sz,'like',x);
end
