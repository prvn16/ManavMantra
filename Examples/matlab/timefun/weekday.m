function [d,w] = weekday(t, varargin)
%WEEKDAY Day of week.
%   DAYNUM = WEEKDAY(T) returns the day of the week number for each element 
%   of T.  T is a numeric array containing serial date numbers.  T can also 
%   be a cell vector or a character matrix containing date strings in one
%   of the following formats (see DATESTR for more details about date 
%   format strings):
%
%       * mm/dd/yyyy
%       * dd-mmm-yyyy
%       * yyyy-mm-dd
%
%   For date strings in another format, use WEEKDAY(DATENUM(DATE,FORMAT)).
%
%   WEEKDAY assigns the days of the week the following values in DAYNUM:
%
%      Sun: 1, Mon: 2, Tue: 3, Wed: 4, Thu: 5, Fri: 6, Sat: 7
%
%   [DAYNUM,DAYNAME] = WEEKDAY(T) also returns the day name for each 
%   element of T.  DAYNAME contains short day names in English.
%
%   [DAYNUM,DAYNAME] = WEEKDAY(T, DAYFORM) controls the format of the names 
%   in DAYNAME.  When DAYFORM is 'short' (the default), WEEKDAY returns 
%   short day names.  When DAYFORM is 'long', WEEKDAY returns full day 
%   names.
%
%   [DAYNUM,DAYNAME] = WEEKDAY(T, LANGUAGE) controls the language of the 
%   names in DAYNAME.  When LANGUAGE is 'en_US' (the default), WEEKDAY 
%   returns English day names.  When LANGUAGE is 'local', WEEKDAY returns 
%   names in the local language.
%
%   DAYFORM and LANGUAGE are optional and can be combined in any order 
%   following T.
%
%   Examples:
%      [num,name] = weekday(728647)
%      [num,name] = weekday('19-Dec-1994')
%      [num,name] = weekday('19-Dec-1994','long','local')
%      [num,name] = weekday(datenum('12/19/1994','mm/dd/yyyy'))
%
%   See also EOMDAY, DATENUM, DATEVEC.

%   Copyright 1984-2012 The MathWorks, Inc.

if ~isnumeric(t)
    try
        t = datenum(t);
    catch exception
        throw(MException('MATLAB:weekday:ConvertDateString', '%s', exception.message));
    end
end
isshort = 1;
isenglish = 1;
if (nargin > 1 && nargout > 1)
    for i = 1:numel(varargin)
        if strcmpi(varargin(i), 'local')
            isenglish = 0;
        elseif strcmpi(varargin(i), 'en_us')
            isenglish = 1;
        elseif strcmpi(varargin(i), 'short')
            isshort = 1;
        elseif strcmpi(varargin(i), 'long')
            isshort = 0;
        else
            error(message('MATLAB:weekday:InvalidOption',varargin{i}));
        end
    end
    if isenglish
        if isshort
            form = 'short';
        else
            form = 'long';
        end
    else
        if isshort
            form = 'shortloc';
        else
            form = 'longloc';
        end
    end
    
    if ischar(form)
        week = getweekdaynamesmx(form);
    end;
elseif nargout > 1
    week = getweekdaynamesmx;
end;

d = mod(fix(t)-2,7)+1;

if nargout > 1
    %Optimization.  If the input array is short, it is more efficient to do
    %the second.  If it is very long, it is more efficient to do the first.
    if numel(d) > 50
        week1 = strvcat(week); %#ok
        w = week1(d,:);
    else
        w = strvcat(week{d});  %#ok
    end
end

