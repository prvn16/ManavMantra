function c = ldivide(a,b)
%LDIVIDE Left division for durations.
%   B = X .\ A scales the elements in the duration array A by the corresponding
%   elements of the numeric array X. A and X must have the same sizes, or either
%   can be a scalar.
%
%   C = B .\ A returns the ratio of the corresponding elements of the duration
%   arrays A and B. A and B must have the same sizes, or either can be a scalar.
%  
%   LDIVIDE(X,A) or LDIVIDE(B,A) is called for the syntax 'X .\ A' or B .\ A'.
%
%   See also PLUS, MINUS, TIMES, MLDIVIDE, RDIVIDE, DURATION.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.validateScaleFactor
import matlab.internal.datatypes.throwInstead

try
    
    if isa(a,'duration')
        if isa(b,'duration')
            c = a.millis .\ b.millis; % unitless numeric result
        else
            error(message('MATLAB:duration:DurationDivisionNotDefined',class(b)));
        end
    else % isa(b,'duration')
        % Numeric input a is interpreted as a scale factor.
        try
            a = validateScaleFactor(a);
        catch ME
            throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:DivisionNotDefined',class(a),class(b)));
        end
        c = b;
        c.millis = a .\ b.millis;
    end
    
catch ME
    throwAsCaller(ME);
end
