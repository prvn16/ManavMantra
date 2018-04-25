function mustBeLessThan(A, B)
%MUSTBELESSTHAN Validate that value is less than a specified value or issue error
%   MUSTBELESSTHAN(A,B) issues an error if A is not less than B.
%   MATLAB calls lt to determine if A is less than B.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       lt, isscalar, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
    
%   Copyright 2016 The MathWorks, Inc.

    validateInputsForBinaryComparisonFunction(A, B, 'mustBeLessThan');

    if ~all(A(:) < B)
        throw(createValidatorExceptionWithValue(...
            createPrintableScalar(B),...
            'MATLAB:validators:mustBeLessThanGenericText',...
            'MATLAB:validators:mustBeLessThan'));
    end
end
