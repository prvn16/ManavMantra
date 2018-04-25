function mustBeNumeric(A)
%MUSTBENUMERIC Validate that value is numeric or issue error
%   MUSTBENUMERIC(A) issues an error if A contains nonnumeric values. 
%   MATLAB call isnumeric to determine if a value is numeric.
%
%   See also: isnumeric
        
%   Copyright 2016 The MathWorks, Inc.
    
    if ~isnumeric(A)
        throw(createValidatorException('MATLAB:validators:mustBeNumeric'));
    end
end

