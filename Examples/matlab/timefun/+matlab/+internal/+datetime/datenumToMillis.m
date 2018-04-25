function millis = datenumToMillis(x,allowNonDouble)

%   Copyright 2014 The MathWorks, Inc.

try
    
    if isa(x,'double') || islogical(x)
        if ~isreal(x)
            error(message('MATLAB:datetime:ComplexNumeric'));
        end
        millis = x * 86400000; % days -> ms
    elseif (nargin == 2) && allowNonDouble && isnumeric(x)
        if ~isreal(x)
            error(message('MATLAB:datetime:ComplexNumeric'));
        end
        millis = double(x) * 86400000; % days -> ms
    else
        error(message('MATLAB:datetime:DurationConversion'));
    end
    
catch ME
    throwAsCaller(ME);
end
