function d = caldiff(a,components,dim)
%CALDIFF Successive differences between datetimes as calendar durations.
%   D = CALDIFF(T) returns an array of calendar durations D containing time
%   differences between successive datetimes in T in terms of the calendar
%   components years, months, days, and time.
%
%   To compute successive differences between datetimes in T1 and T2 as exact
%   fixed-length durations, use DIFF(T).
%
%   When T is a vector, D is
%      [BETWEEN(T(1),T(2)), BETWEEN(T(2),T(3)), ..., BETWEEN(T(END-1),T(END))].
%
%   When T is a matrix, D(:,I) is
%      [BETWEEN(T(1,I),T(2,I), BETWEEN(T(2,I),T(3,I)), ..., BETWEEN(T(END-1,I),T(END,I))].
%
%   When T is an N-D array, D contains differences along the first non-singleton
%   dimension of T.
%
%   D = CALDIFF(T,COMPONENTS) finds the differences between successive datetimes
%   in T in terms of the specified calendar/time components. COMPONENTS is one
%   of the character vectors 'Years', 'Quarters, 'Months', 'Weeks', 'Days', or 'Time', or
%   a cell array containing one or more of those character vectors. CALDIFF operates on
%   the calendar/time components in decreasing order, largest first. T(2:END) is
%   not equal to T(1:END-1) + D in general, unless you include 'Time' as one of
%   the specified components.
%
%   The calendar components 'Years', 'Quarters, 'Months', 'Weeks', and 'Days'
%   are flexible lengths of time. For example, 1 month represents a different
%   length of time when you add it to a datetime in January than when you add it
%   to a datetime in February. Use DIFF(T) to find the exact time difference
%   between successive elements of T in exact fixed-length units of hours,
%   minutes, and seconds.
%
%   D = CALDIFF(X,COMPONENTS,DIM) is the difference along dimension DIM.
%
%   Examples:
%
%      % Create a sequence of random datetimes and find the number of calendar
%      % days between each.
%      t = datetime(2014,1:2:12,1) + caldays(randi([0 15],1,6))
%      d1 = caldiff(t,'Days')
%
%      % Find the number of months and calendar days between each datetime.
%      d2 = caldiff(t,{'Months' 'Days'})
%
%      % Find the exact time difference between between each in hours/minutes/seconds.
%      d3 = diff(t)
%
%   See also DIFF, BETWEEN, MINUS, PLUS, COLON, CALENDARDURATION.

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datetime.diffDateFields
import matlab.internal.datatypes.isScalarInt
import matlab.internal.datatypes.stringToLegacyText

if nargin > 1
    components = stringToLegacyText(components);
end

narginchk(1,3);

data = a.data;
if nargin < 3
    dim = find(size(data)~=1,1);
    if isempty(dim), dim = 1; end
else
    if ~isScalarInt(dim,1)
        error(message('MATLAB:datetime:InvalidDim'));
    end
end
[aData,bData] = lagData(data,dim);
ucal = datetime.dateFields;
fieldIDs = [ucal.EXTENDED_YEAR ucal.QUARTER ucal.MONTH ucal.WEEK_OF_YEAR ucal.DAY_OF_MONTH ucal.MILLISECOND_OF_DAY];
if (nargin == 1) || isempty(components)
    fields = [1 3 5 6];
    [cdiffs{1:4}] = diffDateFields(aData,bData,fieldIDs(fields),a.tz);
    d = calendarDuration(cdiffs{:});
else
    fields = unique(checkComponents(components));
    cdiffs = {0 0 0 0 0 0};
    [cdiffs{fields}] = diffDateFields(aData,bData,fieldIDs(fields),a.tz);
    cdiffs{3} = cdiffs{3} + 3*cdiffs{2}; % add quarters into months
    cdiffs{5} = cdiffs{5} + 7*cdiffs{4}; % add weeks into days
    fmt = 'yqmwdt'; fmt = fmt(union(fields,[3 5 6])); % always include mdt
    d = calendarDuration(cdiffs{[1 3 5 6]},'Format',fmt);
end


%-------------------------------------------------------------------------------
function [aData,bData] = lagData(data,dim)
if ismatrix(data)
    if dim == 1
        aData = data(1:end-1,:);
        bData = data(2:end,:);
    elseif dim == 2
        aData = data(:,1:end-1);
        bData = data(:,2:end);
    else
        aData = zeros([size(data) 0]);
        bData = zeros([size(data) 0]);
    end
else
    szOut = size(data);
    if dim > length(szOut), szOut(end+1:dim) = 1; end
    szOut(dim) = szOut(dim) - 1;
    
    subs = repmat({':'},1,length(szOut));
    subs{dim} = 1:szOut(dim);
    aData = reshape(data(subs{:}),szOut);
    subs{dim} = subs{dim} + 1;
    bData = reshape(data(subs{:}),szOut);
end
