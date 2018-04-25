function x = validateScaleFactor(x,allowNonDouble)

%   Copyright 2014 The MathWorks, Inc.

try
    
    if isa(x,'double') || islogical(x)
        if ~isreal(x)
            error(message('MATLAB:datetime:ComplexNumeric'));
        end
    elseif (nargin == 2) && allowNonDouble && isnumeric(x)
        if ~isreal(x)
            error(message('MATLAB:datetime:ComplexNumeric'));
        end
        x = double(x); % days -> ms
    else
        error(message('MATLAB:datetime:DurationConversion'));
    end
    
catch ME
    throwAsCaller(ME);
end
