function c = plus(a,b)
%PLUS Datetime addition.
%   T2 = T1 + D or T2 = D + T1 adds D to the datetimes in T1, and returns the
%   result in a datetime array T2. D is an array of durations or calendar
%   durations. D can also be a numeric scalar, interpreted as a number of 24
%   hour days. T1 and D must have the same dimensions, or either may be a
%   scalar.
%
%   Addition between two datetime arrays is not defined.
%
%   A duration represents a length of time in terms of standard fixed-length
%   hours, minutes, and seconds. Adding a duration to a datetime adds exactly
%   that length of time. The date/time representation of the result may appear
%   off by 1 hour or 1 day, because of daylight saving time changeovers or
%   leap days.
%
%   A calendar duration represents a period of time in terms of flexible-length
%   calendar units. Adding a calendar duration to a datetime adds an amount of
%   time whose length depends on the datetime value. However, the date/time
%   representation of the result will be consistent with the amounts that were
%   added to each calendar component.
%
%   Examples:
%
%      % Add 1:5 minutes to the current time, and find the time differences
%      % between the original datetime and the result.
%         t1 = datetime('now')
%         t2 = t1 + minutes(1:5)
%         dt = t2 - t1
%
%      % Add 1 calendar day to datetimes just before the US spring and fall Daylight
%      % Saving Time changes, and find the time difference between the original
%      % datetimes and the result.
%         strs = {'10-Mar-2013 00:00:00' '03-Jun-2013 00:00:00' '03-Nov-2013 00:00:00'}
%         t1 = datetime(strs,'TimeZone','America/New_York')
%         t2 = t1 + caldays(1)
%         dt = t2 - t1
%         dt2 = between(t1,t2,'Days')
%
%   See also MINUS, BETWEEN, COLON, DIFF, CALDIFF, DURATION, CALENDARDURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.datetimeAdd
import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

try

    [a,b] = datetime.arithUtil(a,b); % durations become numeric, in days
    
    if isa(a,'datetime')
        if isa(b,'datetime')
            error(message('MATLAB:datetime:DatetimeAdditionNotDefined'));
        end
        c = a;
        op = b;
    else %isa(b,'datetime')
        c = b;
        op = a;
    end
    
    needsTime = true;
    if isa(op,'duration')
        c.data = datetimeAdd(c.data,milliseconds(op));
    elseif isa(op,'calendarDuration')
        ucal = datetime.dateFields;
        [op_fields{1:3}] = split(op,{'month' 'day' 'time'});
        op_fields{3} = milliseconds(op_fields{3});
        fieldIDs = [ucal.MONTH ucal.DAY_OF_MONTH ucal.MILLISECOND_OF_DAY];
        c.data = addToDateFields(c.data,op_fields,fieldIDs,c.tz);
        needsTime = any(op_fields{3}(:) ~= 0);
    else
        try
            ms = datenumToMillis(op);
        catch ME
            throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:datetime:AdditionNotDefined',class(c),class(op)));
        end
        % Add a multiple of 24 hours
        c.data = datetimeAdd(c.data,ms);
    end
        
    if isempty(c.fmt) && needsTime
        c.isDateOnly = false;
    end

catch ME
    throwAsCaller(ME);
end
