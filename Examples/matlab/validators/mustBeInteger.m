function mustBeInteger(A)
%MUSTBEINTEGER Validate that value is integer or issue error
%   MUSTBEINTEGER(A) issues an error if A contains non integer values.
%   A value is integer if it is real, finite, and equal to the result 
%   of taking the floor of the value.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       isreal, isfinite, floor, isnumeric, islogical, eq
%
%   See also: mustBeNumericOrLogical, mustBeReal
    
% Copyright 2016 The MathWorks, Inc.
    
    if ~isNumericOrLogical(A)
        throw(createValidatorException('MATLAB:validators:mustBeNumericOrLogical'));
    end

    if ~isreal(A)
        throw(createValidatorException('MATLAB:validators:mustBeReal'));
    end
    
    if ~all(isfinite(A(:))) || ~all(A(:) == floor(A(:)))
        throw(createValidatorException('MATLAB:validators:mustBeInteger'));
    end
end
