function c = plus(a,b)
%PLUS Addition for durations.
%   C = A + B adds the duration arrays A and B. A and B must have the same
%   sizes, or either can be a scalar. You can also add an array of durations to
%   an array of datetimes or to an array of calendar durations.
%
%   You can also add a numeric array to a duration array. Numeric values are
%   treated as numbers of standard 24-hour days. In other words, if X is a
%   numeric array, then A + X is equivalent to A + HOURS(24*X).
%  
%   PLUS(A,B) is called for the syntax 'A + B'.
%
%   See also SUM, MINUS, DURATION, DATETIME, CALENDARDURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.datenumToMillis
import matlab.internal.datatypes.throwInstead

try

    % datetime and calendarDuration are superor, dispatch goes there
    
    if isa(a,'duration')
        if isa(b,'duration')
            % Add one duration to another.
            c = a;
            c.millis = a.millis + b.millis;
        else
            % Add a number of standard days to a duration.
            try
                bmillis = datenumToMillis(b);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:AdditionNotDefined',class(a),class(b)));
            end
            c = a;
            c.millis = a.millis + bmillis;
        end
    else % isa(b,'duration')
        % Add a number of standard days to a duration.
        try
            amillis = datenumToMillis(a);
        catch ME
            throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:AdditionNotDefined',class(a),class(b)));
        end
        c = b;
        c.millis = amillis + b.millis;
    end

catch ME
    throwAsCaller(ME);
end
