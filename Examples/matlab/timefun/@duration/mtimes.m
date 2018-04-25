function c = mtimes(a,b)
%MTIMES Matrix multiplication for durations.
%   B = A * X scales and sums the rows of the duration array A by the columns of
%   the numeric array X. B = X * A scales and sums the columns of A by the rows
%   of X. A and X must have the compatible sizes, or either can be a scalar.
%  
%   MTIMES(A,X) is called for the syntax 'A * X'.
%
%   See also PLUS, MINUS, TIMES, DURATION.

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
            c.millis = a.millis * b;
        end
    elseif isa(b,'duration')
        try
            a = validateScaleFactor(a);
        catch ME
            throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:MultiplicationNotDefined',class(a),class(b)));
        end
        c = b;
        c.millis = a * b.millis;
    end

catch ME
    throwAsCaller(ME);
end
