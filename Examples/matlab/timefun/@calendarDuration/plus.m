function c = plus(a,b)
%PLUS Addition for calendar durations.
%   C = A + B adds the calendar duration arrays A and B. A and B must have
%   the same sizes, or either can be a scalar. You can also add an array of
%   calendar durations to an array of datetimes or to an array of durations.
%
%   You can also add a numeric array to a calendar duration array. Numeric
%   values are treated as numbers of standard 24-hour days. In other words,
%   if X is a numeric array, then A + X is equivalent to A + HOURS(24*X).
%  
%   PLUS(A,B) is called for the syntax 'A + B'.
%
%   See also MINUS, DAYS, CALENDARDURATION, DATETIME, DURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

try

    % datetime is superior, dispatch goes there
    
    if isa(a,'calendarDuration')
        c = a;
        c_components = c.components;
        if isa(b,'calendarDuration')
            % Add two calendarDurations.
            b_components = b.components;
            c_components.months = c_components.months + b_components.months;
            c_components.days   = c_components.days + b_components.days;
            c_components.millis = c_components.millis + b_components.millis;
            c.fmt = calendarDuration.combineFormats(a.fmt,b.fmt);
        elseif isa(b,'duration')
            % Add a duration to a calendarDuration.
            c_components.millis = c_components.millis + milliseconds(b);
        else
            % Add a multiple of 24 hours to a calendarDuration.
            try
                bmillis = datenumToMillis(b);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:calendarDuration:AdditionNotDefined',class(a),class(b)));
            end
            c_components.millis = c_components.millis + bmillis;
        end
    else % isa(b,'calendarDuration')
        c = b;
        c_components = c.components;
        if isa(a,'duration')
            % Add a duration to a calendarDuration.
            c_components.millis = c_components.millis + milliseconds(a);
        else
            % Add a whole number of days to a calendarDuration.
            try
                amillis = datenumToMillis(a);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:calendarDuration:AdditionNotDefined',class(a),class(b)));
            end
            c_components.millis = c_components.millis + amillis;
        end
    end
    c_components = calendarDuration.expandScalarFields(c_components);
    c.components = calendarDuration.reconcileNonfinites(c_components);

catch ME
    throwAsCaller(ME);
end
