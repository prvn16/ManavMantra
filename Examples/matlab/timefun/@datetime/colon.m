function c = colon(a,d,b)
%COLON Create equally-spaced sequence of datetimes.
%   A:B creates a sequence of datetimes with a step size of 1 calendar day. A
%   and B are scalar datetimes. A:B is the same as [A, A+CALDAYS(1), A+CALDAYS(2),
%   ..., C1], where C-CALDAYS(1) < C1 <= C. A:B:C is empty if A > B.
%
%   D = A:B:C creates a sequence of datetimes with steps of length B. A and
%   C are scalar datetimes, or either can be text representing date/time. B
%   is a scalar duration or calendar duration. B can also be a numeric
%   scalar, interpreted as a number of 24 hour days. A:B:C is the same as
%   [A, A+B, A+B+B, ..., C1], where C-B < C1 <= C. A:B:C is empty if B ==
%   0, if B > 0 and A > C, or if B < 0 and A < C.
%
%   A duration represents a length of time in terms of the standard fixed-length
%   time units hours, minutes, and seconds. Adding a duration to a datetime adds
%   exactly that length of time. The date/time representation of the result may
%   appear off by 1 hour or 1 day, because of daylight saving time changeovers
%   or leap days.
%
%   A calendar duration represents a period of time in terms of flexible-length
%   calendar units. Adding a calendar duration to a datetime adds an amount of
%   time whose length depends on the datetime value. However, the date/time
%   representation of the result will be consistent with the amounts that were
%   added to each calendar component.
%
%   Examples:
%
%      % Create a sequence of datetimes 1.5 minutes apart, and then find the
%      % time difference between the successive datetimes.
%         t1 = datetime('now')
%         t2 = t1 + minutes(5)
%         t = t1:minutes(1.5):t2
%         dt = diff(t)
%
%      % Create a sequence of datetimes 1 day apart, beginning just before a
%      % daylight saving time change, and find the time difference between the
%      % successive datetimes.
%         t1 = datetime('01-Nov-2013 08:00:00','TimeZone','America/New_York')
%         t2 = datetime('05-Nov-2013 08:00:00','TimeZone','America/New_York')
%         t = t1:caldays(1):t2
%         dt = diff(t)
%         dtDays = caldiff(t,'Days')
%
%   See also PLUS, MINUS, LINSPACE, DIFF, BETWEEN, DURATION, CALENDARDURATION

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datetime.addToDateField
import matlab.internal.datetime.datetimeAdd
import matlab.internal.datetime.datetimeSubtract
import matlab.internal.datetime.datenumToMillis
import matlab.internal.datetime.diffDateFields
import matlab.internal.datatypes.throwInstead

try

    if nargin < 3
        b = d;
        d = caldays(1);
    else
        if isa(d,'duration')
            % Step by a duration.
            d = milliseconds(d);
        elseif isa(d,'calendarDuration')
            % Step by a calendarDuration.
        else
            % Numeric input interpreted as a number of fixed-length days.
            try
                d = datenumToMillis(d);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:datetime:colon:NonNumericStep'));
            end
        end
    end

    try
        [a_data,b_data,c] = datetime.compareUtil(a,b);
    catch ME
        throwInstead(ME,'MATLAB:datetime:InvalidComparison',message('MATLAB:datetime:colon:InvalidColon'));
    end

    if ~isscalar(a_data) || ~isscalar(b_data) || ~isscalar(d)
        if numel(a_data)>1 || numel(b_data)>1 || numel(d)>1
            error(message('MATLAB:datetime:colon:NonScalarInputs'));
        end
        
        % Either a_data, b_data or d is empty at this point (non-empty ones
        % are scalar), colon returns 1x0 datetime consistent with builtin
        c.data = colon([],[]);
        return;
    end

    if isnumeric(d) % d was a duration, or numeric
        c_data = datetimeAdd(a_data,colon(0,d,datetimeSubtract(b_data,a_data)));
    else
        [dt(1),dt(2)] = split(d,{'month' 'day'}); dt(3) = milliseconds(time(d));
        ucal = datetime.dateFields;
        if sum(dt ~= 0) > 1 % mixed-calendar-units step size
            c_tz = c.tz;
            c_data = a_data;
            fieldIDs = [ucal.MONTH ucal.DAY_OF_MONTH ucal.MILLISECOND_OF_DAY];
            while datetimeSubtract(c_data(end),b_data) < 0
                % If b contains both days and months, a + b + ... + b is not necessarily the
                % same as a + i*b. This is the former.
                a_data = addToDateFields(a_data,{dt(1) dt(2) dt(3)},fieldIDs,c_tz);
                c_data(end+1) = a_data; %#ok<AGROW>
            end
            if datetimeSubtract(c_data(end),b_data) > 0
                c_data(end) = [];
            end
        elseif dt(1) ~= 0 % faster calculation for pure calendar months step size
            c_data = addToDateField(a_data,colon(0,dt(1),diffDateFields(a_data,b_data,ucal.MONTH,c.tz)),ucal.MONTH,c.tz);
        elseif dt(2) ~= 0 % faster calculation for pure calendar days step size
            if isempty(c.tz)
                % For unzoned datetimes, days is equivalent to caldays but faster
                c_data = datetimeAdd(a_data,colon(0,datenumToMillis(dt(2)),datetimeSubtract(b_data,a_data)));
            else
                c_data = addToDateField(a_data,colon(0,dt(2),diffDateFields(a_data,b_data,ucal.DAY_OF_MONTH,c.tz)),ucal.DAY_OF_MONTH,c.tz);
            end
        else % dt(3) ~= 0,  faster calculation for pure time step size
            c_data = datetimeAdd(a_data,colon(0,dt(3),datetimeSubtract(b_data,a_data)));
        end
    end
    c.data = c_data;

catch ME
    throwAsCaller(ME);
end
