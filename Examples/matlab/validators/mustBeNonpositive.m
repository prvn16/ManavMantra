function mustBeNonpositive(A)
%MUSTBENONPOSITIVE Validate that value is not positive or issue error
%   MUSTBENONPOSITIVE(A) issues an error if A contains positive values.
%   A value is positive if it is greater than zero.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       le, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
        
%   Copyright 2016 The MathWorks, Inc.
    
    validateInputForUnaryComparisonFunction(A);
    
    if ~all(A(:) <= 0)
        throw(createValidatorException('MATLAB:validators:mustBeNonpositive'));
    end
end
