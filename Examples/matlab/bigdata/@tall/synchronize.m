function ttOut = synchronize(varargin)
%SYNCHRONIZE Synchronize tall timetables.
%   TT = SYNCHRONIZE(TT1,TT2);
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMEBASIS)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMESTEP)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMES)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMEBASIS,METHOD)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMESTEP,METHOD)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMES,METHOD)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMEBASIS,...,'PARAM1',val1,'PARAM2',val2,...)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMESTEP,...,'PARAM1',val1,'PARAM2',val2,...)
%   TT = SYNCHRONIZE(TT1,TT2,NEWTIMES,...,'PARAM1',val1,'PARAM2',val2,...)
%   TT = SYNCHRONIZE(TT1,TT2,...,TTN,NEWTIMEBASIS,METHOD,...)
%   TT = SYNCHRONIZE(TT1,TT2,...,TTN,NEWTIMESTEP,METHOD,...)
%   TT = SYNCHRONIZE(TT1,TT2,...,TTN,NEWTIMES,METHOD,...)
%
%   Limitations:
%   1) NEWTIMES must be strictly increasing instead of strictly monotonic.
%   2) Option 'commonrange' is not supported.
%   3) Interpolation method 'spline' is not supported.
%   4) Name value pair 'EndValues' is not supported.
%
%   See also TIMETABLE/SYNCHRONIZE

%   Copyright 2017 The MathWorks, Inc.

% Count the number of timetable inputs, get their workspace names, and make sure they all
% have the same kind of time vector.
timetableInputNames = cell(1,nargin);
ntimetables = 0;
haveDurations = false;
hasVariableContinuity = false;
for i = 1:nargin
    if istimetable(varargin{i})
        varargin{i} = tall(varargin{i});
    end   
    if ~(istall(varargin{i}) && isequal(tall.getClass(varargin{i}), 'timetable'))
       break
    end
    ntimetables = i;
    timetableInputNames{i} = inputname(i);
    timevec = subsref(varargin{i}, substruct('.', 'Properties', '.', 'RowTimes')); 
    if isequal(tall.getClass(timevec),'duration') ~= haveDurations
        if ntimetables > 1
            error(message('MATLAB:timetable:synchronize:MixedTimeTypes'));
        else
            haveDurations = true;
        end
    end
    vcp = subsref(varargin{i}, substruct('.', 'Properties', '.', 'VariableContinuity'));
    hasVariableContinuity = hasVariableContinuity || ~isempty(vcp);
end
if ntimetables == 0
    error(message('MATLAB:timetable:synchronize:NonTimetableInput'));
end

timetableInputs = varargin(1:ntimetables);
timetableInputNames = timetableInputNames(1:ntimetables);

endValues = 'extrap';
includedEdge = 'left';
isIncludedLeftEdge = true;
fillConstant = 0;
isAggregation = false;
hasMonotonReq = false;
isStrictlyMonotonic = false;

if nargin == ntimetables
    % Sync to the union of the time vectors, fill unmatched rows with missing
    method = 'NoSpecificMethod';
    [RegularTimeVector, timeStep, boundary, useTimeVec] =  ...
        processNewTimesInput('union',timetableInputs,includedEdge,isAggregation,hasMonotonReq,isStrictlyMonotonic);
    parameterInputs = {};
else
    if nargin == ntimetables + 1
        % Sync to the specified time vector, fill unmatched rows with missing
        if hasVariableContinuity 
            method = 'NoSpecificMethod';
        else 
            method = 'fillwithmissing';
        end
        parameterInputs = {};
    else % nargin >= ntimetables + 2
        % Sync using the specified method. Call processMethodInput to get errors on the
        % method before errors on the optional inputs.
        [method,isAggregation,hasMonotonReq,isStrictlyMonotonic,supportedTypes] = ...
            processMethodInput(varargin{ntimetables+2});
        parameterInputs = varargin(ntimetables+3:end);
        
        iValidateTypes(supportedTypes, method, timetableInputs);
        
        if ~isAggregation && strcmp(method,'spline')
            error(message('MATLAB:bigdata:array:SynchronizeMethodNotSupported',method));
        end
        if nargin > ntimetables + 2
            pnames = {   'Constant' 'EndValues' 'IncludedEdge'};
            dflts =  {fillConstant   endValues   includedEdge };
            [fillConstant,endValues,includedEdge] ...
                = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{ntimetables+3:end});
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
                isIncludedLeftEdge = strcmp(includedEdge, 'left');
            catch
                error(message('MATLAB:timetable:synchronize:InvalidIncludedEdge'));
            end
        end
    end
    % Sync to the specified time vector.
    [RegularTimeVector, timeStep, boundary, useTimeVec] = ...
        processNewTimesInput(varargin{ntimetables+1},timetableInputs,includedEdge,isAggregation,hasMonotonReq,isStrictlyMonotonic);
    if (haveDurations && ~strcmp(tall.getClass(RegularTimeVector),'duration')) || ...
       (~haveDurations && ~strcmp(tall.getClass(RegularTimeVector),'datetime'))
        error(message('MATLAB:timetable:synchronize:MixedTimeTypesNewTimes'));
    end
end

% Repartition all tall timetables according to boundary
tY = cell(size(timetableInputs));
for i = 1:numel(tY)
    tY{i} = sortTimetableWithPartition(@(x)sortrows(x), timetableInputs{i}, boundary, isIncludedLeftEdge);
end
ttime = sortTimetableWithPartition(@(x)sort(x), RegularTimeVector, boundary, isIncludedLeftEdge);

% The last (or first depending on isIncludedLeftEdge) time bin only
% accumulates things that have that exact time value.
exactOnlyBinTime = getExactOnlyBinTime(RegularTimeVector, isIncludedLeftEdge);

% Now start to synchronize
if isAggregation || any(strcmp(method,{'fillwithmissing', 'fillwithconstant'}))
    
    func = @(varargin)synchronize(varargin{:},method,parameterInputs{:});
    [adaptor, outputVarNames] = createAdaptor(timetableInputs, timetableInputNames, timeStep, func);
    % Aggregation and fill methods
    funcTimeVec = func;
    if useTimeVec
        % Special case for count'count'
        % Call with 'count' would result in wrong counts.
        % Replace the call with 'fillwithconstant'.
        if strcmp('count',method)
            funcTimeVec = @(varargin)synchronize(varargin{:},'fillwithconstant',parameterInputs{:});
        end
    end
    ttOut = generalpartitionfun(@(varargin)iSyncIt(varargin{:}, timeStep, func, useTimeVec, outputVarNames, funcTimeVec, isIncludedLeftEdge), tY{:}, ttime, exactOnlyBinTime);
    ttOut.Adaptor = adaptor;

else

    if strcmp(method, 'NoSpecificMethod')
       func = @(varargin)synchronize(varargin{:},'fillwithmissing',parameterInputs{:});
    else
       func = @(varargin)synchronize(varargin{:},method,parameterInputs{:});
    end
    [adaptor, outputVarNames] = createAdaptor(timetableInputs, timetableInputNames, timeStep, func);
    
    % Nearest and Interpolation methods
    locfunc = @(varargin)synchronize(varargin{:},'fillwithmissing');
    if useTimeVec
        tY{end+1} = timetable(ttime);
    end
    if strcmp(timeStep,'intersection')
        ttOut = generalpartitionfun(@(varargin)iSyncIt(varargin{:}, 'intersection', locfunc, false, outputVarNames, locfunc, isIncludedLeftEdge), tY{:}, ttime, exactOnlyBinTime);
        ttOut.Adaptor = adaptor;
        ttime = subsref(ttOut, substruct('.', 'Properties', '.', 'RowTimes'));
        useTimeVec = true;
    end
    ttOut = generalpartitionfun(@(varargin)iSyncIt(varargin{:}, 'union', locfunc, false, outputVarNames, locfunc, isIncludedLeftEdge), tY{:}, ttime, exactOnlyBinTime);
    ttOut.Adaptor = adaptor;

    if strcmp(method, 'NoSpecificMethod')
        vcprops = subsref(ttOut, substruct('.', 'Properties', '.', 'VariableContinuity'));
        if ~isempty(vcprops)
            fillMethods = {vcprops.InterpolationMethod};
            fillMethods = cellfun(@char, fillMethods, 'UniformOutput', false);
            ttOut = groupFillMissing(ttOut, fillMethods, 'linear');
            ttOut = groupFillMissing(ttOut, fillMethods, 'previous');
        end
    else
        ttOut = fillmissing(ttOut, method);
    end
    if useTimeVec
        % There will be no missing value to be filled.
        % But you need to pass in a method to avoid default behavior
        % with VariableContinuity
        ttOut = synchronize(ttOut,ttime,'fillwithmissing');
    end
    
end

% ttOut is derived from generalpartitionfun. The framework assumes this
% will be partition dependent. We need to correct this because the output
% of tall/synchronize is not.
if isPartitionIndependent(varargin{:})
    ttOut = markPartitionIndependent(ttOut);
end

%-------------------------------------------------------------------------------
function iValidateTypes(supportedTypes, method, timetableInputs)
% Helper to validate that all table columns are supported for the
% selected method. Only columns with known types are checked here. Unknown
% typed columns will be checked lazily on the workers as part of the
% calculation.
if isempty(supportedTypes)
    % All types supported
    return
end

for tt=1:numel(timetableInputs)
    thisTT = timetableInputs{tt};
    for vv=1:width(thisTT)
        clz = thisTT.Adaptor.getVariableClass(vv);
        if ~isempty(clz) && ~matlab.bigdata.internal.util.isSupportedClass(clz, supportedTypes)
            msg = message('MATLAB:timetable:synchronize:NotNumeric1', method);
            throwAsCaller(MException(msg.Identifier, '%s', getString(msg)));
        end
    end
end

%-------------------------------------------------------------------------------
function tt = groupFillMissing(tt, fillMethods, meth)
% fill all the variables with default fill option meth.
ind = strcmp(fillMethods,meth); 
if any(ind)
    adaptor = tt.Adaptor;
    ttTmp = subsref(tt, substruct('()', {':', ind}));
    ttTmp = fillmissing(ttTmp, meth);
    tt = slicefun(@(x,y)replaceTimetableVariable(x,y,ind),tt,ttTmp);
    tt.Adaptor = adaptor;
end

%-------------------------------------------------------------------------------
function ttOut = replaceTimetableVariable(ttOut, ttIn, ind)
% Swap the values of the ind-th variable  of timetable ttOut
% with the values in timetable ttIn
ttOut(:,ind) = ttIn;

%-------------------------------------------------------------------------------
function [newAdaptor, varNames] = createAdaptor(timetableInputs, timetableInputNames, timeStep, func)
% Create adaptors from timetable

% Workout the appropriate output variable Name.
varNames = uniqueifyVarNames(timetableInputs,timetableInputNames);

requiresVarMerging = false;
timetableAdaptors = cellfun(@matlab.bigdata.internal.adaptors.getAdaptor, ...
    timetableInputs, 'UniformOutput', false);
[newAdaptor, varNames] = joinBySample(...
    @(varargin) iFixedNameSync(func, varNames, timeStep, varargin{:}), ...
    requiresVarMerging, timetableAdaptors{:});


function out = iFixedNameSync(func, varNames, timeStep, varargin)
out = func(varargin{:}, timeStep);
out.Properties.VariableNames = varNames;

%-------------------------------------------------------------------------------
function [hasfinished, unusedInputs, tout] = iSyncIt(info, varargin)
% Compute synchronize with timetables
% iSyncIt(info, timetable1, ..., timetablen, RegularTimeVector, exactOnlyBinTime, timeStep, func, useTimeVec, outputVarNames, funcTimeVec, isIncludedLeftEdge)
hasfinished = all(info.IsLastChunk);
isLastTimetableChunk = info.IsLastChunk(1 : end - 2);

isIncludedLeftEdge = varargin{end};
funcTimeVec = varargin{end-1};
outputVarNames = varargin{end-2};
useTimeVec = varargin{end-3};
func = varargin{end-4};
timeStep = varargin{end-5};
exactOnlyBinTime = varargin{end-6};
RegularTimeVector = varargin{end-7};
timetableInputs = varargin(1:end-8);

if hasfinished
    % If all inputs are finished, all remaining input data will be consumed
    % by this invocation of iSyncIt. We have no need to pass any input to
    % the next chunk.
    unusedInputs = [];
else
    % Otherwise we want to pass forward any input data we cannot use in
    % this invocation to the next chunk. This is done by giving such data
    % to unusedInputs, as this will be prepended to the next chunk.
    
    maxTimePerTimetableInput = cellfun(@(x) max(x.Properties.RowTimes, [], 1), ...
        timetableInputs, 'UniformOutput', false);
    maxTimePerTimetableInput(isLastTimetableChunk) = cellfun(@(x) getInfLike(inf, x), ...
        maxTimePerTimetableInput(isLastTimetableChunk), 'UniformOutput', false);
    % Any empties above means the input was empty while not finished. We
    % treat such case as inputs missing from the chunk.
    isInputMissing = any(cellfun(@(x) size(x, 1) == 0, maxTimePerTimetableInput));
    % As the inputs are in sorted order, we guarantee to have received all
    % data up-to the maximum time value of each input. This chunk cannot
    % consume past that point as we cannot guarantee we've received all the
    % data beyond that point.
    minRequiredTimeForNextChunk = min(vertcat(maxTimePerTimetableInput{:}), [], 1);
    
    % If using time vector, we must snap chunk boundaries to the time
    % vector. This is to ensure all data for a time bin is in the same
    % chunk as its corresponding time vector value.
    if useTimeVec && ~isInputMissing
        lastTimeOfChunk = RegularTimeVector(find(RegularTimeVector < minRequiredTimeForNextChunk, 1, 'last'));
        
        % We count the case where we don't have any time values within the
        % consumable time range as that input being missing.
        isInputMissing = isInputMissing || isempty(lastTimeOfChunk);
    else
        lastTimeOfChunk = minRequiredTimeForNextChunk;
    end
    
    if isInputMissing
        % If any input is missing, we cannot do anything in this chunk.
        % Pass everything to the next chunk via unusedInputs.
        unusedTimetableInputs = timetableInputs;
        timetableInputs = cellfun(@(x) x([], :), timetableInputs, 'UniformOutput', false);
        unusedRegularTimeVector = RegularTimeVector;
        RegularTimeVector = RegularTimeVector([], :);
    elseif useTimeVec && ~isIncludedLeftEdge
        % Include everything up-to and including lastTimeOfChunk. This is
        % required for include into right edge because the right edge must
        % be part of the same chunk as data immediately prior to it. Note,
        % this does not violate minRequiredTimeForNextChunk because
        % lastTimeOfChunk < minRequiredTimeForNextChunk. Everything else
        % is passed to the next chunk via unusedInputs.
        unusedTimetableInputs = cellfun(@(x) x(~(x.Properties.RowTimes <= lastTimeOfChunk), :), ...
            timetableInputs, 'UniformOutput', false);
        timetableInputs = cellfun(@(x) x((x.Properties.RowTimes <= lastTimeOfChunk), :), ...
            timetableInputs, 'UniformOutput', false);
        
        unusedRegularTimeVector = RegularTimeVector(~(RegularTimeVector <= lastTimeOfChunk), :);
        RegularTimeVector = RegularTimeVector(RegularTimeVector <= lastTimeOfChunk, :);
    else
        % Include everything up-to but excluding lastTimeOfChunk. This is
        % required for include into left edge because the rightmost time
        % value must be moved to the next chunk to be in the same chunk as
        % the data immediately following to it. Everything else is passed
        % to the next chunk via unusedInputs.
        unusedTimetableInputs = cellfun(@(x) x(~(x.Properties.RowTimes < lastTimeOfChunk), :), ...
            timetableInputs, 'UniformOutput', false);
        timetableInputs = cellfun(@(x) x((x.Properties.RowTimes < lastTimeOfChunk), :), ...
            timetableInputs, 'UniformOutput', false);
        
        if useTimeVec
            unusedRegularTimeVector = RegularTimeVector(~(RegularTimeVector < lastTimeOfChunk), :);
            RegularTimeVector = RegularTimeVector(RegularTimeVector < lastTimeOfChunk, :);
        else
            unusedRegularTimeVector = RegularTimeVector([], :);
        end
    end
    
    unusedInputs = [unusedTimetableInputs, {unusedRegularTimeVector}, {exactOnlyBinTime}];
end

% Two calls to work around the binning behavior between
% timestep and timevector
tout = func(timetableInputs{:},timeStep);
if useTimeVec
    % When IncludeEdge is 'right', this function can be given data that is
    % at time before the first time value of the chunk. In the majority of
    % cases, we want to include that data into the first bin of the chunk.
    % This is done by adding a preceding negative inf before calling
    % synchronize on the chunk.
    %
    % The exception to the rule is the very first time bin of the tall array,
    % represented by exactOnlyBinTime, which should only accumulate data
    % that exactly matches the time value.
    needPrecedingInf =  ~isIncludedLeftEdge ...
        && ~isempty(RegularTimeVector) && height(tout) ~= 0 ...
        && tout.Properties.RowTimes(1) < RegularTimeVector(1) ...
        && (isempty(exactOnlyBinTime) || exactOnlyBinTime ~= RegularTimeVector(1));
    
    % When IncludeEdge is 'left', this function can be given data that is
    % at time after the last time value of the chunk. In the majority of
    % cases, we want to include that data into the last bin of the chunk.
    % This is done by adding a trailing positive inf before calling
    % synchronize on the chunk.
    %
    % The exception to the rule is the very last time bin of the tall array,
    % represented by exactOnlyBinTime, which should only accumulate data
    % that exactly matches the time value. We do this by adding a
    % trailing inf when necessary.
    needTrailingInf = isIncludedLeftEdge ...
        && ~isempty(RegularTimeVector) && height(tout) ~= 0 ...
        && tout.Properties.RowTimes(end) > RegularTimeVector(end) ...
        && (isempty(exactOnlyBinTime) || exactOnlyBinTime ~= RegularTimeVector(end));
    
    if needPrecedingInf
        RegularTimeVector = [getInfLike(-inf, RegularTimeVector); RegularTimeVector];
        binIdxToRemove = 1;
    elseif needTrailingInf
        RegularTimeVector = [RegularTimeVector; getInfLike(inf, RegularTimeVector)];
        binIdxToRemove = numel(RegularTimeVector);
    end
    
    tout = funcTimeVec(tout,RegularTimeVector);
    
    if needTrailingInf || needPrecedingInf
        tout(binIdxToRemove, :) = [];
    end
end

if ~isempty(outputVarNames)
    tout.Properties.VariableNames = outputVarNames;
end

%-------------------------------------------------------------------------------
function [method,isAggregation,hasMonotonReq,isStrictlyMonotonic,supportedTypes] = processMethodInput(method)
% Validate the method input and check if it is an aggregation method.
import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isCharStrings
isStrictlyMonotonic = false;
hasMonotonReq = false;
supportedTypes = {}; % Default to allowing all types
if isCharString(method)
    method = lower(method);
    switch method
        % When evaluated at times that are in an input's time vector, these
        % methods simply repeat that input's data, untouched. So if the target
        % is one of the inputs' time vectors, that input need not be worked on.
        case {'previous' 'next' 'nearest'}
            isAggregation = false;
            hasMonotonReq = true;
        case {'linear' 'spline' 'pchip'}
            isAggregation = false;
            isStrictlyMonotonic = true;
            hasMonotonReq = true;
            supportedTypes = {'numeric','datetime','duration'};
        case {'fillwithmissing' 'fillwithconstant'}
            isAggregation = false;
            
            % The next cases all (potentially) modify data even when evaluated at times
            % that are in an input's original time vector. So even if the target is
            % one of the inputs' time vectors, calculation must still be done on
            % that input.
        case {'count' 'firstvalue' 'lastvalue'}
            isAggregation = true;
        case {'min' 'max'}
            isAggregation = true;
            supportedTypes = {'numeric','datetime','duration','categorical'};
        case {'sum' 'mean' 'prod'}
            isAggregation = true;
            supportedTypes = {'numeric','datetime','duration'};
            
        otherwise
            % The argument was a name but not a method name.
            error(message('MATLAB:timetable:synchronize:UnrecognizedMethod',method));
    end
elseif isa(method,'function_handle')
    isAggregation = true;
else
    % The argument was not a method name or a function handle.
    error(message('MATLAB:timetable:synchronize:InvalidMethod'));
end

%-------------------------------------------------------------------------------
function [newTimes, timeStep, boundary, useTimeVec] = processNewTimesInput(newTimes,timetableInputs,includedEdge,isAggregation,hasMonotonReq,isStrictlyMonotonic)
% Validate the newTimeBasis, newTimeStep, or newTimes input, and compute the
% actual time vector for newTimeBasis or newTimeStep
import matlab.internal.datatypes.isCharString

if isduration(newTimes) || isdatetime(newTimes)
    %Limitation. Need to allow decreasing.
    if ~issorted(newTimes,'strictascend')
        error(message('MATLAB:bigdata:array:SynchronizeDecreasingTimeNotSupported'));
    end
    newTimes = tall(newTimes(:));
    timeStep = 'union';
    boundary = createRepartitionEdge(newTimes);
    useTimeVec = true;
elseif istall(newTimes) && any(strcmp(tall.getClass(newTimes), {'datetime', 'duration'}))
    %Limitation. Need to allow decreasing.
    newTimes = lazyValidate(newTimes, {@(x)issorted(x,'strictascend'), ...
        'MATLAB:bigdata:array:SynchronizeDecreasingTimeNotSupported'});
    timeStep = 'union';
    boundary = createRepartitionEdge(newTimes);
    useTimeVec = true;
elseif isCharString(newTimes)
    switch lower(newTimes)
    case {'union', 'intersection'}
        [tt, ttIdx] = getTimetableWithMostPartitionWithCheck(timetableInputs{:},isAggregation,hasMonotonReq,isStrictlyMonotonic);
        if isAggregation && (lower(newTimes) == "intersection")
            % For intersection aggregation synchronize, we require partition
            % boundaries to align with the intersection of row times. We do
            % this by converting the problem into an explicit time vector
            % aggregation synchronize.
            timeStep = 'union';
            newTimes = getIntersectionRowTimes(timetableInputs{ttIdx}, timetableInputs{[1 : ttIdx - 1, ttIdx + 1 : end]});
            useTimeVec = true;
        else
            timeStep = lower(newTimes);
            newTimes = subsref(tt, substruct('.', 'Properties', '.', 'RowTimes'));
            useTimeVec = false;
        end
        boundary = createRepartitionEdge(newTimes);
    case 'commonrange'
        error(message('MATLAB:bigdata:array:SynchronizeTimeBasisNotSupported')); %Limitation: Not supported
    case 'first'
        newTimes = subsref(timetableInputs{1}, substruct('.', 'Properties', '.', 'RowTimes'));
        %Limitation. Need to allow decreasing.
        newTimes = lazyValidate(newTimes, {@(x)issorted(x,'strictascend'), ...
            'MATLAB:bigdata:array:SynchronizeDecreasingTimeNotSupported'});
        getTimetableWithMostPartitionWithCheck(timetableInputs{:},isAggregation,hasMonotonReq,isStrictlyMonotonic);
        timeStep = 'union';
        boundary = createRepartitionEdge(newTimes);
        useTimeVec = true;     
    case 'last'
        newTimes = subsref(timetableInputs{end}, substruct('.', 'Properties', '.', 'RowTimes'));
        %Limitation. Need to allow decreasing.
        newTimes = lazyValidate(newTimes, {@(x)issorted(x,'strictascend'), ...
            'MATLAB:bigdata:array:SynchronizeDecreasingTimeNotSupported'});
        getTimetableWithMostPartitionWithCheck(timetableInputs{:},isAggregation,hasMonotonReq,isStrictlyMonotonic);
        timeStep = 'union';
        boundary = createRepartitionEdge(newTimes);
        useTimeVec = true; 
    otherwise
        newTimeStep = newTimes;
        timeStep = newTimeStep;
        useTimeVec = true;
        [tmin,tmax] = getCommonTimeRange(timetableInputs);
        if istall(tmin) && isequal(tall.getClass(tmin),'datetime')
            switch lower(newTimeStep)
            case 'secondly',  timeStepName = 'second';  newTimeStep = seconds(1);
            case 'minutely',  timeStepName = 'minute';  newTimeStep = minutes(1);
            case 'hourly',    timeStepName = 'hour';    newTimeStep = hours(1);
            case 'daily',     timeStepName = 'day';     newTimeStep = caldays(1);
            case 'weekly',    timeStepName = 'week';    newTimeStep = calweeks(1);
            case 'monthly',   timeStepName = 'month';   newTimeStep = calmonths(1);
            case 'quarterly', timeStepName = 'quarter'; newTimeStep = calquarters(1);
            case 'yearly',    timeStepName = 'year';    newTimeStep = calyears(1);
            otherwise
                error(message('MATLAB:timetable:synchronize:UnknownNewTimeStep',newTimeStep));
            end
            % Choose newTimes to span the row times of the inputs, as the floor/ceil of
            % tmin/tmax w.r.t the specified unit, equal to tmin/tmax if that falls on a
            % whole unit.
            tleft = dateshift(tmin,'start',timeStepName); % floor
            tright = dateshift(tmax,'start',timeStepName); % first step in ceil
            tright = tright + (tright < tmax) * newTimeStep; % second step in ceil
        else
            switch lower(newTimeStep)
            case 'secondly',  timeStepName = 'seconds';  newTimeStep = seconds(1);
            case 'minutely',  timeStepName = 'minutes';  newTimeStep = minutes(1);
            case 'hourly',    timeStepName = 'hours';    newTimeStep = hours(1);
            case 'daily',     timeStepName = 'days';     newTimeStep = days(1);
            case 'yearly',    timeStepName = 'years';    newTimeStep = years(1);
            case {'weekly' 'monthly' 'quarterly'}
                error(message('MATLAB:timetable:synchronize:UnknownNewTimeStepDuration',newTimeStep));
            otherwise
                error(message('MATLAB:timetable:synchronize:UnknownNewTimeStep',newTimeStep));
            end
            % Choose newTimes to span the row times of the inputs. See comments above.
            tleft = floor(tmin,timeStepName);
            tright = ceil(tmax,timeStepName);
        end    
        if isAggregation && strcmp(includedEdge, 'right')
             tleft  = tleft + (tleft ~= tmin) .* newTimeStep;
             tright = tright + (tright ~= tmax) .* newTimeStep;
        end
        tt = getTimetableWithMostPartitionWithCheck(timetableInputs{:},isAggregation,hasMonotonReq,isStrictlyMonotonic);
        [newTimes, boundary] = createNewTimeVector(tt, tleft, tright, newTimeStep, tmax, timeStepName, isAggregation);
    end
else
    error(message('MATLAB:timetable:synchronize:InvalidNewTimes'));
end
newTimes = newTimes(:); % force everything to a column

%-------------------------------------------------------------------------------
function [tt, ttIdx] = getTimetableWithMostPartitionWithCheck(varargin)
% getTimetableWithMostPartition returns the tall timetable with the largest
% number of partitions and check the monotonicity requirement.
isAggregation = varargin{end-2};
hasMonotonReq = varargin{end-1};
isStrictlyMonotonic = varargin{end};

tt = varargin{1};
ttIdx = 1;
numPartitions = numpartitions(hGetValueImpl(tt));
tt = requireMonotonicity(tt,isAggregation,hasMonotonReq,isStrictlyMonotonic);
for ii = 2:(numel(varargin)-3)
    ttmp = varargin{ii};
    k = numpartitions(hGetValueImpl(ttmp));
    ttmp = requireMonotonicity(ttmp,isAggregation,hasMonotonReq,isStrictlyMonotonic);
    if k > numPartitions
        numPartitions = k;
        tt = ttmp;
        ttIdx = ii;
    end
end

%-------------------------------------------------------------------------------
function tt = requireMonotonicity(tt,isAggregation,hasMonotonReq,isStrictlyMonotonic)
if ~isAggregation && hasMonotonReq
    if isStrictlyMonotonic
        f = @(x)issorted(subsref(x, substruct('.', 'Properties', '.', 'RowTimes')),'strictascend');
    else
        f = @(x)issorted(subsref(x, substruct('.', 'Properties', '.', 'RowTimes')),'ascend');
    end
    tt = lazyValidate(tt, {f, 'MATLAB:bigdata:array:SynchronizeDecreasingTimeNotSupported'});
end

%-------------------------------------------------------------------------------
function [tmin,tmax] = getCommonTimeRange(timetableInputs)
% Find the common time range of the timetable's time vectors
getRowTimesFcn = @(tt) subsref(tt, substruct('.', 'Properties', '.', 'RowTimes'));

if numel(timetableInputs) == 1
    % Synchronizing a single timetable, faster to directly evaluate bounds
    [tmin, tmax] = bounds(getRowTimesFcn(timetableInputs{1}));
    return;
end

% Find the min and max RowTimes across all input timetables
rowTimes = cellfun(getRowTimesFcn, timetableInputs, 'UniformOutput', false);
[minRowTimes, maxRowTimes] = cellfun(@bounds, rowTimes, 'UniformOutput', false);

[tmin, tmax] = clientfun(...
    @(varargin) bounds(vertcat(varargin{:})), ...
    minRowTimes{:}, maxRowTimes{:});

% Setup adaptors so that the outputs have the correct types.  Sizes are
% irrelevant for these internal variables.  The first input time vector is
% used as this should be the dominant one for Format, et al properties.
adaptor = resetSizeInformation(rowTimes{1}.Adaptor);
tmin.Adaptor = adaptor;
tmax.Adaptor = adaptor;

%-------------------------------------------------------------------------------
function allVarNames = uniqueifyVarNames(timetableInputs,timetableInputNames)
% Make unique any variable names that are duplicated across the timetables

% Get the var names in, and the workspace name of, each input timetable
nTimetables = length(timetableInputs);
varNames = cell(1,nTimetables);
nVarNames = zeros(1,nTimetables);
for i = 1:nTimetables
    varNames{i} = subsref(timetableInputs{i}, substruct('.', 'Properties', '.', 'VariableNames'));
    nVarNames(i) = numel(varNames{i});
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
end

%-----------------------------------------------------------------
function [tv, boundary] = createNewTimeVector(tallArray, tbegin, tend, stride, tmax, timeStepName, isAggregation)
% createNewTimeVector create a tall time column with number of partition
% taken from tallArray.
paX = hGetValueImpl(tallArray);
numPartitions = numpartitions(paX);

if iscalendarduration(stride)
    numElem = split(between(tbegin, tend, timeStepName), timeStepName) + 1;
else
    numElem = (tend - tbegin)/stride + 1;   % Number of Elements in the time vector.
end
numElemPerPartition = ceil(numElem / numPartitions);

[tv, boundary] = partitionfun(@localColVec, tallArray,  tbegin, tend, stride, numElemPerPartition, tmax, isAggregation);
tv.Adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(tall.getClass(tbegin));
boundary.Adaptor = resetSizeInformation(tv.Adaptor);

%-----------------------------------------------------------------
function [isfinished, v, boundary] = localColVec(info, tA, tbegin, tend, stride, n, tmax, isAggregation)
% create local part for the Column vector according to the partition ID.
k = info.PartitionId;  % assume 1,2,3,4,5,...
isfinished = info.IsLastChunk;

locBegin = tbegin + (k-1)*n*stride;
locEnd = tbegin + (k*n - 1)*stride;
if locEnd >= tend
    locEnd = tend; % make sure the vector ends in tend
    if tend > tmax && isAggregation
       locEnd = locEnd - stride; % One less due to have synchronize bin data in time vector.
    end
end 

v = locBegin:stride:locEnd;
v = v(:); % Always a column vector
if isfinished
    if k == 1 || isempty(v)
        boundary = v([],1);
    else
        boundary = v(1);
    end
else
    v = v([],1);
    boundary = v;
end

%-----------------------------------------------------------------
function boundary = createRepartitionEdge(tColVec)
% Create partition boundary from tColVec
boundary = partitionfun(@localBoundary, tColVec);
boundary.Adaptor = resetSizeInformation(tColVec.Adaptor);

%-----------------------------------------------------------------
function [isfinished, boundary] = localBoundary(info, v)
% create local part for the Column vector according to the partition ID.
k = info.PartitionId;
isfinished = info.IsLastChunk;

if k == 1 || isempty(v) || info.RelativeIndexInPartition ~= 1
    boundary = v([],1);
else
    boundary = v(1);
end

%-----------------------------------------------------------------
function tY = sortTimetableWithPartition(sortFunctionHandle, tX, tNewPartitionBoundaries, isIncludeLeftEdge)
%sortTimetableWithPartition sorts with a particular boundary.
% See SORTCOMMON for more detail.

import matlab.bigdata.internal.FunctionHandle;
import matlab.bigdata.internal.io.ExternalSortFunction;
import matlab.bigdata.internal.broadcast;
import matlab.bigdata.internal.PartitionMetadata;
import matlab.bigdata.internal.util.isBroadcast;

% This algorithm uses partitioned array instead of tall so that the adaptor
% information isn't needed for update till the very end.
paX = hGetValueImpl(tX);
paNewPartitionBoundaries = hGetValueImpl(tNewPartitionBoundaries);

numPartitions = numpartitions(paNewPartitionBoundaries);

if ~(isBroadcast(paX) && isBroadcast(paNewPartitionBoundaries))
    % Need to estimate how to distribute the data among workers evenly.
    paNewPartitionBoundaries = broadcast(paNewPartitionBoundaries);
    
    fh = @(varargin) iDiscretize(sortFunctionHandle,varargin{:},isIncludeLeftEdge);
    paRedistributeKeys = slicefun(fh, paX, paNewPartitionBoundaries);
    paX = repartition(PartitionMetadata(numPartitions), paRedistributeKeys, paX);
end

paX = partitionfun(FunctionHandle(ExternalSortFunction(sortFunctionHandle)), paX);

tY = tall(paX, tX.Adaptor);

%-----------------------------------------------------------------
function keys = iDiscretize(sortFunctionHandle, x, boundaries, isIncludedLeftEdge)
% Discretize an input array based on sortrow criterion and a set of
% boundaries.
if istimetable(x)
    x = x.Properties.RowTimes;
end
if isempty(x)
    keys = zeros(size(x, 1), 1);
else
    boundaries = unique(boundaries); %boundaries can have duplicate and not sorted
    t = [x; boundaries];
    [~, idx] = feval(sortFunctionHandle, t);
    boundaryIndices = find(idx > size(x, 1));
    sortedKeys = discretize((1 : size(x, 1) + size(boundaries, 1))', [-Inf; boundaryIndices; Inf]);
    keys = zeros(size(idx, 1), 1);
    keys(idx, :) = sortedKeys;
    keys(end - size(boundaries,1) + 1 : end, :) = [];
    % If the boundaries and x has the same values and isIncludeLeftEdge is
    % true, we need put those values to the next partition.
    if isIncludedLeftEdge
        keys = keys + ismember(x,boundaries);
    end
end

%-----------------------------------------------------------------
function value = getExactOnlyBinTime(RegularTimeVector, isIncludedLeftEdge)
% Get the time of the time bin that has different behaviour to all other bins.
% This bin only accumulates values that have the exact same time value.
if isIncludedLeftEdge
    value = tail(RegularTimeVector, 1);
else
    value = head(RegularTimeVector, 1);
end
% Broadcast to deal with the case where RegularTimeVector is empty.
value = matlab.bigdata.internal.broadcast(value);

%-----------------------------------------------------------------
function val = getInfLike(val, likeParameter)
% Return an inf like the given data. This returns a double for things that
% aren't datetime because duration can vertically concatenate with double.
if isdatetime(likeParameter)
    val = datetime(val, val, val, 'TimeZone', likeParameter.TimeZone);
elseif isduration(likeParameter)
    val = duration(val, val, val, 'Format', likeParameter.Format);
end

%-----------------------------------------------------------------
function newTimes = getIntersectionRowTimes(varargin)
% Get a tall array that represents the intersection of the row times of the
% given tall timetables.

% We do not need the actual data at this point, this function is only going
% to communicate and use the row times.
for ii = 1 : numel(varargin)
    varargin{ii} = subsref(varargin{ii}, substruct('.', 'Properties', '.', 'RowTimes'));
end

% Repartition and sort all tall row times according to a common boundary.
% This is required to meet the assumptions of intersectSortedRowTimeChunks.
boundary = createRepartitionEdge(varargin{1});
for ii = 1 : numel(varargin)
    varargin{ii} = sortTimetableWithPartition(@(x)sort(x), varargin{ii}, boundary, false);
end

newTimes = generalpartitionfun(@intersectSortedRowTimeChunks, varargin{:});
newTimes.Adaptor = resetTallSize(matlab.bigdata.internal.adaptors.getAdaptor(varargin{1}));

%-----------------------------------------------------------------
function [hasFinished, unusedInputs, newTimes] = intersectSortedRowTimeChunks(info, varargin)
% Generalpartitionfun implementation that intersects two or more tall
% arrays of row times. This assumes that the tall arrays were previously
% sorted and repartitioned to have the same partition boundary time values.

hasFinished = all(info.IsLastChunk);
if hasFinished
    % It is safe to use all remaining input in this chunk.
    unusedInputs = [];
else
    % For each input, it is safe to use up-to but excluding the maximum
    % because the input is in sorted order. The next chunk will only have
    % values greater than or equal to the maximum we've seen.
    minUnsafeTimePerInput = cellfun(@(x) max(x, [], 1), varargin, 'UniformOutput', false);
    % If any input is empty, we can't know what values the next chunk will
    % have. To play it safe, we set that input to report all times as
    % unsafe.
    isInputMissing = any(cellfun(@isempty, varargin));
    minUnsafeTimePerInput(isInputMissing) = cellfun(@(x) getInfLike(-inf, x), ...
        minUnsafeTimePerInput(isInputMissing), 'UniformOutput', false);
    % If any input is finished (even if empty), all future chunks of that
    % input will be empty. It is safe to go past it's maximum value.
    minUnsafeTimePerInput(info.IsLastChunk) = cellfun(@(x) getInfLike(inf, x), ...
        minUnsafeTimePerInput(info.IsLastChunk), 'UniformOutput', false);
    
    % The minimum time value that must be sent to the next chunk.
    minRequiredTimeForNextChunk = min(vertcat(minUnsafeTimePerInput{:}), [], 1);
    
    unusedInputs = cellfun(@(x) x(~(x < minRequiredTimeForNextChunk), :), ...
        varargin, 'UniformOutput', false);
    varargin = cellfun(@(x) x(x < minRequiredTimeForNextChunk, :), ...
        varargin, 'UniformOutput', false);
end

newTimes = varargin{1};
for ii = 2 : numel(varargin)
    newTimes = intersect(newTimes, varargin{ii});
end
