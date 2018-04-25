function d = between(a,b,components)
%BETWEEN Difference between datetimes as calendar durations.
%   D = BETWEEN(T1,T2) finds the time differences between the datetimes in T1
%   and T2. D is an array of calendar durations that contains those differences
%   in terms of the calendar components years, months, days, and time, such that
%   T2 = T1 + D.
%
%   To compute differences between datetimes in T1 and T2 as exact fixed-length
%   durations, use T2 - T1.
%
%   D = BETWEEN(T1,T2,COMPONENTS) finds the differences between the datetimes in
%   T1 and T2 in terms of the specified calendar/time components. COMPONENTS is
%   one of the character vectors 'Years', 'Quarters, 'Months', 'Weeks', 'Days', or 'Time',
%   or a cell array containing one or more of those character vectors. BETWEEN operates on
%   the calendar/time components in decreasing order, largest first. T2 is not
%   equal to T1 + D in general, unless you include 'Time' as one of the
%   specified components.
%
%   The calendar components 'Years', 'Quarters, 'Months', 'Weeks', and 'Days'
%   are flexible units of time. For example, 1 month represents a different
%   length of time when you add it to a datetime in January than when you add it
%   to a datetime in February. Use T2 - T1 to find the exact time difference
%   between T2 and T1 in fixed-length units of hours, minutes, and seconds.
%
%   Examples:
%
%      % Create a sequence of datetimes on the next 6 month end days, then find
%      % the number of days between today and the end of each month.
%         t1 = datetime('1-Jan-2013')
%         t2 = dateshift(t1,'end','month',0:5)
%         dtDays = between(t2,t1,'Days')
%
%      % Find the number of months and days between today and the end of each month.
%         dtMonthsDays = between(t2,t1,{'Months' 'Days'})
%
%      % Find the exact length of time between today and the end of each month.
%         dtExact = t2 - t1
%
%      % Add the three time differences to the original datetime
%         t3 = t1 + dtDays
%         t4 = t1 + dtMonthsDays
%         t5 = t1 + dtExact
%
%      % Add the three time differences to the same date in a leap year
%         t6 = datetime('1-Jan-2012')
%         t7 = t6 + dtDays
%         t8 = t6 + dtMonthsDays
%         t9 = t6 + dtExact
%
%   See also MINUS, CALDIFF, DIFF, PLUS, COLON, CALENDARDURATION.

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datetime.diffDateFields

narginchk(2,3);

[a,b] = datetime.arithUtil(a,b);
if ~isa(a,'datetime') || ~isa(b,'datetime')
    error(message('MATLAB:datetime:InvalidComparison',class(a),class(b)));
end

aData = a.data;
bData = b.data;
ucal = datetime.dateFields;
fieldIDs = [ucal.EXTENDED_YEAR ucal.QUARTER ucal.MONTH ucal.WEEK_OF_YEAR ucal.DAY_OF_MONTH ucal.MILLISECOND_OF_DAY];
if nargin < 3
    fields = [1 3 5 6];
    [cdiffs{1:4}] = diffDateFields(aData,bData,fieldIDs(fields),a.tz);
    d = calendarDuration(cdiffs{1:4});
else
    fields = unique(checkComponents(components));
    cdiffs = {0 0 0 0 0 0};
    [cdiffs{fields}] = diffDateFields(aData,bData,fieldIDs(fields),a.tz);
    cdiffs{3} = cdiffs{3} + 3*cdiffs{2}; % add quarters into months
    cdiffs{5} = cdiffs{5} + 7*cdiffs{4}; % add weeks into days
    fmt = 'yqmwdt'; fmt = fmt(union(fields,[3 5 6])); % always include mdt
    d = calendarDuration(cdiffs{[1 3 5 6]},'Format',fmt);
end
