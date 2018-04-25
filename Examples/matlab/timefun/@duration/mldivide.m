function c = mldivide(x,a)
%MLDIVIDE Left matrix division for durations.

% This is a stub whose only purpose is to allow X \ A for scalar numeric X
% without requiring a dot. Matrix division is not defined in general.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.validateScaleFactor
import matlab.internal.datatypes.throwInstead

try

    if isscalar(x) && isa(a,'duration')
        if isa(x,'duration')
            c = x.millis \ a.millis; % unitless numeric result
        else
            % Numeric input x is interpreted as a scale factor.
            try
                x = validateScaleFactor(x);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:MatrixDivisionNotDefined'));
            end
            c = a;
            c.millis = x \ a.millis;
        end
    else
        error(message('MATLAB:duration:MatrixDivisionNotDefined'));
    end

catch ME
    throwAsCaller(ME);
end
