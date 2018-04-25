function mustBeNegative(A)
%MUSTBENEGATIVE Validate that value is negative or issue error
%   MUSTBENEGATIVE(A) issues an error if A contains nonnegative values.
%   A value is negative if it is less than zero.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods: 
%       lt, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
    
%   Copyright 2016 The MathWorks, Inc.

    validateInputForUnaryComparisonFunction(A);

    if ~all(A(:) < 0)
        throw(createValidatorException('MATLAB:validators:mustBeNegative'));
    end
end
