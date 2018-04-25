function c = minus(a,b)
%MINUS Subtraction for durations.
%   C = A - B subtracts the duration arrays A and B. A and B must have the same
%   sizes, or either can be a scalar. You can also subtract an array of
%   durations from an array of datetimes or from an array of calendar durations.
%
%   You can also subtract a numeric array from a duration array. Numeric values
%   are treated as numbers of standard 24-hour days. In other words, if X is a
%   numeric array, then A - X is equivalent to A - HOURS(24*X).
%  
%   MINUS(A,B) is called for the syntax 'A - B'.
%
%   See also DIFF, PLUS, DURATION, DATETIME, CALENDARDURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

try

    % datetime and calendarDuration are superor, dispatch goes there
    
    if isa(a,'duration')
        if isa(b,'duration')
            c = a;
            c.millis = a.millis - b.millis;
        else
            % Subtract a number of standard days from a duration.
            try
                bmillis = datenumToMillis(b);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:SubtractionNotDefined',class(a),class(b)));
            end
            c = a;
            c.millis = a.millis - bmillis;
        end
    else % isa(b,'duration')
        % Subtract a duration from a number of standard days.
        try
            amillis = datenumToMillis(a);
        catch ME
            throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:SubtractionNotDefined',class(a),class(b)));
        end
        c = b;
        c.millis = amillis - b.millis;
    end

catch ME
    throwAsCaller(ME);
end
