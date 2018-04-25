function c = mrdivide(a,x)
%MRDIVIDE Right matrix division for durations.

% This is a stub whose only purpose is to allow A / X for scalar numeric X
% without requiring a dot. Matrix division is not defined in general.

%   Copyright 2014 The MathWorks, Inc.

import matlab.internal.datetime.validateScaleFactor
import matlab.internal.datatypes.throwInstead

try

    if isscalar(x) && isa(a,'duration')
        if isa(x,'duration')
            c = a.millis / x.millis; % unitless numeric result
        else
            % Numeric input a is interpreted as a scale factor.
            try
                x = validateScaleFactor(x);
            catch ME
                throwInstead(ME,'MATLAB:datetime:DurationConversion',message('MATLAB:duration:MatrixDivisionNotDefined'));
            end
            c = a;
            c.millis = a.millis / x;
        end
    else
        error(message('MATLAB:duration:MatrixDivisionNotDefined'));
    end

catch ME
    throwAsCaller(ME);
end
