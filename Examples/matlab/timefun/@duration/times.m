function c = times(a,b)
%MTIMES Multiplication for durations.
%   B = A .* X or B = X .* A scales the elements in the duration array A by the
%   corresponding elements of the numeric array X. A and X must have the same
%   sizes, or either can be a scalar.
%  
%   TIMES(A,X) is called for the syntax 'A .* X'.
%
%   See also PLUS, MINUS, MTIMES, DURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.validateScaleFactor
import matlab.internal.datatypes.throwInstead

try

    % Numeric input interpreted as a scale factor.
    if isa(a,'duration')
        if isa(b,'duration')
            error(message('MATLAB:duration:DurationMultiplicationNotDefined'));
        else
            try
                b = validateScaleFactor(b);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:MultiplicationNotDefined',class(a),class(b)));
            end
            c = a;
            c.millis = a.millis .* b;
        end
    elseif isa(b,'duration')
        try
            a = validateScaleFactor(a);
        catch ME
            throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:MultiplicationNotDefined',class(a),class(b)));
        end
        c = b;
        c.millis = a .* b.millis;
    end

catch ME
    throwAsCaller(ME);
end
