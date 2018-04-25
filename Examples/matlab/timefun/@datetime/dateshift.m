function that = dateshift(this,whereTo,unit,rule)
%DATESHIFT Shift datetimes or generate sequences according to a calendar rule.
%   T2 = DATESHIFT(T,'start',UNIT) shifts each datetime in the array T back to
%   the beginning of the unit of time specified by UNIT. UNIT is 'year',
%   'quarter', 'month', 'week', 'day', 'hour', 'minute', or 'second'. T2 is a
%   datetime array.
%
%   T2 = DATESHIFT(T,'end',UNIT) shifts each datetime in the array T ahead to
%   the end of the unit of time specified by UNIT. UNIT is 'year', 'quarter',
%   'month', 'week', 'day', 'hour', 'minute', or 'second'. The end of a day,
%   hour, minute, or second is also the beginning of the next one. The end of a
%   year, quarter, month, or week is the last day in that time period. T2 is a
%   datetime array.
%
%   T2 = DATESHIFT(T,'dayofweek',DOW) returns the next occurrence of the
%   specified day of the week on or after each datetime in the array T. DOW is a
%   day of week number, or a localized day name. T2 is a datetime array.
%
%   T2 = DATESHIFT(T,...,RULE) shifts the datetimes in the array T ahead or back
%   according to RULE. RULE is one of the character vectors 'next', 'previous', or
%   'nearest'. RULE can also be the character vector 'current' to shift to the start or
%   end of the current unit of time, or to the specified day in the current
%   week.
%
%   DATESHIFT treats the current day as the "next" or "previous" occurrence of
%   the specified day of week if it falls on that day of the week.
%
%   RULE can also be an integer value or an array of integer values. For unit of
%   time, 0 corresponds to the start/end of the current unit for each datetime,
%   1 corresponds to the next, -1 to the previous, etc. For day of the week, 0
%   corresponds to the specified day in the current week for each datetime, 1
%   corresponds to the next occurrence of the specified day, -1 to the previous,
%   etc. T and RULE are the same size, or either one is a scalar.
%
%   Examples:
%
%      % Create an array of datetimes, and find the first and last day of the
%      % month for each one.
%         t = datetime(2013,10,30:33,10,30,0)
%         BoM = dateshift(t,'start','month')
%         EoM = dateshift(t,'end','month')
%
%      % Create sequences of datetimes on the first and last days of each of the
%      % next six months.
%         t = datetime('now')
%         BoM = dateshift(t,'start','month',1:6)
%         EoM = dateshift(t,'end','month',1:6)
%
%      % Create an array of datetimes, and find the first Friday on or
%      % after each one.
%         t = datetime(2013,11,20:24,10,30,0,'Format','eee, dd-MMM-yyyy HH:mm:ss')
%         fridays = dateshift(t,'dayofweek','friday')
%
%      % Create a sequence of datetimes on the next five Fridays.
%         t = datetime('now','Format','eee, dd-MMM-yyyy HH:mm:ss')
%         fridays = dateshift(t,'dayofweek','friday',1:5)
%
%   See also BETWEEN, COLON.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.addToDateField
import matlab.internal.datetime.getDayNames
import matlab.internal.datetime.datetimeSubtract
import matlab.internal.datatypes.isCharString;
import matlab.internal.datatypes.isIntegerVals;
import matlab.internal.datatypes.isScalarInt;
ucal = datetime.dateFields;
thisData = this.data;
tz = this.tz;

% Only unit needs to be converted into char.
if nargin > 2
    unit = matlab.internal.datatypes.stringToLegacyText(unit);
end

try
    whereTo = getChoice(whereTo,{'start' 'end' 'dayofweek'},1:3);
catch ME
    error(message('MATLAB:datetime:dateshift:InvalidWhereTo'));
end
if (whereTo == 1) || (whereTo == 2) % 'start', 'end'
    try
        unit = getChoice(unit,{'year' 'quarter' 'month' 'week' 'day' 'hour' 'minute' 'second'},1:8);
    catch ME
        if strcmp(ME.identifier,'MATLAB:datetime:AmbiguousInput')
            error(message('MATLAB:datetime:dateshift:AmbiguousUnit',unit));
        else
            error(message('MATLAB:datetime:dateshift:InvalidUnit'));
        end
    end
    
    % Move back to the beginning of the current unit
    fieldIDs = [ucal.EXTENDED_YEAR;
        ucal.QUARTER; 
        ucal.MONTH;
        ucal.WEEK_OF_YEAR;
        ucal.DAY_OF_MONTH;
        ucal.HOUR_OF_DAY;
        ucal.MINUTE;
        ucal.SECOND];
    thatData = matlab.internal.datetime.datetimeFloor(thisData,fieldIDs(unit),tz);

    if (nargin < 4) || strcmpi(rule,'current')
        % Already moved back to the start of current unit, done.
    elseif strcmpi(rule,'next')
        thatData = addToDateField(thatData,1,fieldIDs(unit),tz);
    elseif strcmpi(rule,'previous')
        thatData = addToDateField(thatData,-1,fieldIDs(unit),tz);
    elseif strcmpi(rule,'nearest')
        % Already found the start of the current unit, now find the start of the
        % next unit and move to the nearer of the two.
        thatData2 = addToDateField(thatData,1,fieldIDs(unit),tz);
        dCurrent = datetimeSubtract(thisData,thatData,true); % full precision in the inner subtractions
        dNext = datetimeSubtract(thatData2,thisData,true);
        k = datetimeSubtract(dNext,dCurrent) < 0; % elements closer to next than to current
        thatData(k) = thatData2(k);
    elseif isIntegerVals(rule)
        if isscalar(rule)
            rule = repmat(rule,size(thisData));
        elseif isscalar(thisData)
            thatData = repmat(thatData,size(rule));
        elseif ~isequal(size(thisData),size(rule))
            error(message('MATLAB:datetime:dateshift:InputSizeMismatch'));
        end

        % Move n units from the start of the current unit.
        thatData = addToDateField(thatData,rule,fieldIDs(unit),tz);
    else
        error(message('MATLAB:datetime:dateshift:InvalidRule'));
    end
    
    if whereTo == 2 % 'end'
        % Advance by one unit, that's the desired position for second, minute, hour, but
        % one day ahead of the desire position for week, month, quarter, year
        thatData = addToDateField(thatData,1,fieldIDs(unit),tz);

        % Back up by one day for week, month, quarter, year
        if unit <= 4 % year, quarter, month, week
            thatData = addToDateField(thatData,-1,ucal.DAY_OF_MONTH,tz);
        end
    end
    
elseif (whereTo == 3) % 'dayofweek'
    dow = unit;
    if isCharString(unit)
        try
            dow = getChoice(dow,[getDayNames('short') getDayNames('long')],[1:7 1:7]);
        catch ME
            if strcmp(ME.identifier,'MATLAB:datetime:AmbiguousInput')
                throw(ME);
            else
                error(message('MATLAB:datetime:dateshift:InvalidDOW'));
            end
        end
    elseif isScalarInt(dow,1,7)
        % OK
    else
        error(message('MATLAB:datetime:dateshift:InvalidDOW'));
    end

    [thisDay,thisDow] = matlab.internal.datetime.getDateFields(thisData,[ucal.DAY_OF_MONTH ucal.DAY_OF_WEEK],tz);

    if nargin < 4
        thatDay = thisDay + mod(dow-thisDow,7); % next occurrence on or after
    elseif strcmpi(rule,'current') || isequal(rule,0)
        thatDay = thisDay - thisDow + dow; % occurrence during current week
    elseif strcmpi(rule,'next')
        thatDay = thisDay + mod(dow-thisDow,7); % 1st occurrence on or after
    elseif strcmpi(rule,'previous')
        thatDay = thisDay - mod(-(dow-thisDow),7); % 1st occurrence on or before
    elseif strcmpi(rule,'nearest')
        ndays = mod(dow-thisDow,7);
        thatDay = thisDay + ndays - 7*(ndays>3);
    elseif isIntegerVals(rule)
        if isscalar(rule)
            rule = repmat(rule,size(thisData));
        elseif isscalar(thisData)
            thisData = repmat(thisData,size(rule));
        elseif ~isequal(size(thisData),size(rule))
            error(message('MATLAB:datetime:dateshift:InputSizeMismatch'));
        end
        sgn = sign(rule);
        thatDay = thisDay + sgn.*mod(sgn.*(dow-thisDow),7) + 7*(rule-sgn); % n'th occurrence on or after/before
        k = (rule == 0);
        if any(k(:))
            if isscalar(thisData)
                thisDay = repmat(thisDay,size(rule));
                thisDow = repmat(thisDow,size(rule));
            end
            thatDay(k) = thisDay(k) - thisDow(k) + dow; % occurrence during current week
        end
    else
        error(message('MATLAB:datetime:dateshift:InvalidRule'));
    end
    thatData = matlab.internal.datetime.setDateField(thisData,thatDay,ucal.DAY_OF_MONTH,tz);
end

that = this;
that.data = thatData;
