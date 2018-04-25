function c = minus(a,b)
%MINUS Subtraction for calendar durations.
%   C = A - B subtracts the calendar duration arrays A and B. A and B must have
%   the same sizes, or either can be a scalar. You can also subtract an array of
%   calendar durations from an array of datetimes or from an array of durations.
%
%   You can also subtract a numeric array from a calendar duration array.
%   Numeric values are treated as numbers of standard 24-hour days. In other
%   words, if X is a numeric array, then A - X is equivalent to A - HOURS(24*X).
%  
%   MINUS(A,B) is called for the syntax 'A - B'.
%
%   See also PLUS, DAYS, CALENDARDURATION, DATETIME, DURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

try

    % datetime is superor, dispatch goes there
    
    if isa(a,'calendarDuration')
        c = a;
        c_components = c.components;
        if isa(b,'calendarDuration')
            % Subtract one calendarDuration from another.
            b_components = b.components;
            c_components.months = c_components.months - b_components.months;
            c_components.days   = c_components.days - b_components.days;
            c_components.millis = c_components.millis - b_components.millis;
            c.fmt = calendarDuration.combineFormats(a.fmt,b.fmt);
        elseif isa(b,'duration')
            % Subtract a duration from a calendarDuration.
            c_components.millis = c_components.millis - milliseconds(b);
        else
            % Subtract a multiple of 24 hours from a calendarDuration.
            try
                bmillis = datenumToMillis(b);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:calendarDuration:SubtractionNotDefined',class(a),class(b)));
            end
            c_components.millis = c_components.millis - bmillis;
        end
    else % isa(b,'calendarDuration')
        c = b;
        c_components = c.components;
        c_components.months = -c_components.months;
        if isa(a,'duration')
            % Subtract a calendarDuration from a duration.
            c_components.days = -c_components.days;
            c_components.millis = milliseconds(a) - c_components.millis;
        else
            % Subtract a calendarDuration from a multiple of 24 hours.
            try
                amillis = datenumToMillis(a);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:calendarDuration:SubtractionNotDefined',class(a),class(b)));
            end
            c_components.days = -c_components.days;
            c_components.millis = amillis - c_components.millis;
        end
    end
    c_components = calendarDuration.expandScalarFields(c_components);
    c.components = calendarDuration.reconcileNonfinites(c_components);

catch ME
    throwAsCaller(ME);
end
