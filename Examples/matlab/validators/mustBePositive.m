function mustBePositive(A)
%MUSTBEPOSITIVE Validate that value is positive or issue error
%   MUSTBEPOSITIVE(A) issues an error if A contains nonpositive values.
%   A value is positive if it is greater than zero.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       gt, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
        
%   Copyright 2016 The MathWorks, Inc.

    validateInputForUnaryComparisonFunction(A);

    if ~all(A(:) > 0)
        throw(createValidatorException('MATLAB:validators:mustBePositive'));
    end
end
