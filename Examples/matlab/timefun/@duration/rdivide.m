function c = rdivide(a,b)
%RDIVIDE Right division for durations.
%   B = A ./ X scales the elements in the duration array A by the corresponding
%   elements of the numeric array X. A and X must have the same sizes, or either
%   can be a scalar.
%
%   C = A ./ B returns the ratio of the corresponding elements of the duration
%   arrays A and B. A and B must have the same sizes, or either can be a scalar.
%  
%   RDIVIDE(A,X) or RDIVIDE(A,B) is called for the syntax 'A .\ X' or A .\ B'.
%
%   See also PLUS, MINUS, TIMES, MRDIVIDE, LDIVIDE, DURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.validateScaleFactor
import matlab.internal.datatypes.throwInstead

try

    if isa(a,'duration')
        if isa(b,'duration')
            c = a.millis ./ b.millis; % unitless numeric result
        else
            % Numeric input b is interpreted as a scale factor.
            try
                b = validateScaleFactor(b);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:DivisionNotDefined',class(a),class(b)));
            end
            c = a;
            c.millis = a.millis ./ b;
        end
    else % isa(b,'duration')
        error(message('MATLAB:duration:DurationDivisionNotDefined',class(a)));
    end

catch ME
    throwAsCaller(ME);
end
