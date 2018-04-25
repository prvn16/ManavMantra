function [tf,dt] = isRegularTimeVector(t,unit)
% Determine if a duration or datetime vector is regular with respect to a given
% time/date unit, i.e., has a unique non-zero time step that can be expressed
% entirely in terms of that unit and nothing larger or smaller. E.g., a time
% step of 3q is regular with respect to quarters and months but not with respect
% to years or days.
%
% Also return the time step in the specified unit.

%   Copyright 2017 The MathWorks, Inc.

if nargin < 2
    unit = 'time';
elseif matlab.internal.datatypes.isCharString(unit) % only one unit allowed
    componentNames = {'years' 'quarters' 'months' 'weeks' 'days' 'time'};
    i = find(strncmpi(unit, componentNames,max([1,length(unit)]))); % max prevents matchng empty char vector
    if isempty(i) || ~isscalar(i)
        error(message('MATLAB:datetime:InvalidSingleComponent'));
    end
    unit = componentNames{i};
else
    error(message('MATLAB:datetime:InvalidSingleComponent'));
end

haveDatetime = isa(t,'datetime');
haveDuration = isa(t,'duration');

if ~(haveDatetime || haveDuration) || ~(isvector(t) || all(size(t) == 0)) % 0x0 is a special case
    error(message('MATLAB:datetime:MustBeTimeVector'));
end

if isempty(t) || isscalar(t)
    % An empty, scalar, or non-vector timetable is not regular -- no well-defined time step.
    tf = false;
    dt = duration.fromMillis(NaN);
elseif strcmp(unit,'time')
    % Find the mean time step.
    range = t(end) - t(1);
    
    if range == 0
        % A timetable with constant row times is not regular - no well-defined time step
        tf = false;
    else
        % Tolerance is relative to the magnitude of the largest time.
        if haveDatetime
            % Treat a datetime as an origin plus a duration vector.
            tol = 3*eps(milliseconds(abs(range)));
        else
            tol = 3*eps(milliseconds(max(abs(t))));
        end
        % Compare each time difference to their mean.
        dtMean = range / (length(t)-1);
        tf = all(abs(milliseconds(diff(t) - dtMean)) < tol);
    end
    
    if tf
        dt = dtMean;
        if milliseconds(dt) < 1000
            % Display a sub-second time step as pure seconds.
            dt.Format = 's';
        end
    else
        dt = duration.fromMillis(nan);
    end

elseif haveDatetime
    % Find the unique successive differences in terms of the specified calendar
    % unit and any remaining time and split them into those components.
    dt = unique(caldiff(t,{unit 'time'}));
    [dtSplit,dtSplitTime] = split(dt,{unit 'time'});
    
    % There must be a unique time step with no pure time component and a finite
    % non-zero calendar unit component.
    if isscalar(dtSplit) && (dtSplitTime == 0)
        if (dtSplit ~= 0) && isfinite(dtSplit)
            tf = true;
            % dt is already calculated
        else
            tf = false;
            dt = caldays(nan);
        end
    else
        tf = false;
        dt = caldays(nan);
    end
    
elseif haveDuration
    % A duration time vector is never regular w.r.t. a calendar unit
    tf = false;
    dt = duration.fromMillis(NaN);
end
