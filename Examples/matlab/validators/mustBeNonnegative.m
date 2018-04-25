function mustBeNonnegative(A)
%MUSTBENONNEGATIVE Validate that value is nonnegative or issue error
%   MUSTBENONNEGATIVE(A) issues an error if A contains negaitive values.
%   A value is nonnegative if it is greater than or equal to zero.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       ge, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
    
%   Copyright 2016 The MathWorks, Inc.

    validateInputForUnaryComparisonFunction(A);
    
    if ~all(A(:) >= 0)
        throw(createValidatorException('MATLAB:validators:mustBeNonnegative'));
    end
end
