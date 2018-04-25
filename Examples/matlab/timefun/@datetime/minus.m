function c = minus(a,b)
%MINUS Datetime subtraction.
%   T2 = T1 - D subtracts D from the datetimes in T1, and returns the result in
%   a datetime array T2. D is an array of durations or calendar durations.  D
%   can also be a numeric scalar, interpreted as a number of 24 hour days. T1
%   and D must have the same dimensions, or either may be a scalar.
%
%   D = T2 - T1 subtracts the datetimes in T1 from the datetimes in T2, and
%   returns the result in a duration array T2. T1 and T2 must have the same
%   dimensions, or either may be a scalar. Either T1 or T2 may also be a
%   datetime string or a cell array of datetime strings.
%
%   Subtraction of a datetime array from duration or calendar durations is
%   not defined.
%
%   A duration represents a length of time in terms of standard fixed-length
%   hours, minutes, and seconds. Subtracting a duration from a datetime
%   subtracts exactly that length of time.  The date/time representation of the
%   result may appear off by 1 hour or 1 day, because of Daylight Saving Time
%   changeovers or leap days.
%
%   A calendar duration represents a period of time in terms of flexible-length
%   calendar units. Subtracting a calendar duration from a datetime subtracts an
%   amount of time whose length depends on the datetime value. However, the
%   date/time representation of the result will be consistent with the amounts
%   that were subtracted from each calendar component.
%
%   Examples:
%
%      % Subtract 1 minute from the current time, and find the durations between
%      % the original datetime and the result.
%         t1 = datetime('now')
%         t2 = t1 - minutes(1:5)
%         dt = t1 - t2
%
%      % Subtract 1 calendar day from datetimes just after the US spring and fall
%      % Daylight Saving Time changes, and find the time difference between the
%      % original datetimes and the result.
%         strs = {'10-Mar-2013 12:00:00' '03-Jun-2013 12:00:00' '03-Nov-2013 12:00:00'}
%         t1 = datetime(strs,'TimeZone','America/New_York')
%         t2 = t1 - caldays(1)
%         dt = t2 - t1
%         dt2 = between(t1,t2,'Days')
%
%   See also BETWEEN, DIFF, CALDIFF, PLUS, COLON, DURATION, CALENDARDURATION.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.internal.datetime.datetimeSubtract
import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

try

    [a,b] = datetime.arithUtil(a,b);
    
    needsTime = true;

    if isa(a,'datetime')
        if isa(b,'datetime')
            % Return the duration between two datetimes
            ms = datetimeSubtract(a.data,b.data);
            c = duration.fromMillis(ms);
        else
            c = a;
            if isa(b,'duration')
                c.data = datetimeSubtract(c.data,milliseconds(b),true);
            elseif isa(b,'calendarDuration')
                [b_fields{1:3}] = split(b,{'month' 'day' 'time'});
                b_fields{3} = milliseconds(b_fields{3});
                ucal = datetime.dateFields;
                fieldIDs = [ucal.MONTH ucal.DAY_OF_MONTH ucal.MILLISECOND_OF_DAY];
                c.data = subtractFromDateFields(c.data,b_fields,fieldIDs,c.tz);
                needsTime = any(b_fields{3}(:) ~= 0);
            else
                try
                    ms = datenumToMillis(b);
                catch ME
                    throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:datetime:SubtractionNotDefined',class(b),class(a)));
                end
                % Subtract a multiple of 24 hours
                c.data = datetimeSubtract(c.data,ms,true);
            end
            
            if isempty(c.fmt) && needsTime
                c.isDateOnly = false;
            end
        end
    else % isa(b,'datetime')
        error(message('MATLAB:datetime:SubtractionNotDefined',class(b),class(a)));
    end
catch ME
    throwAsCaller(ME);
end
