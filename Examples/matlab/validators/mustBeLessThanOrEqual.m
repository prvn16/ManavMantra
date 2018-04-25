function mustBeLessThanOrEqual(A, B)
%MUSTBELESSTHANOREQUAL Validate that value is less than or equal to a specified value or issue error
%   MUSTBELESSTHANOREQUAL(A,B) issues an error if A is not less than or equal to B.
%   MATLAB calls le to determine if A is less than or equal to B.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       le, isscalar, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
    
%   Copyright 2016 The MathWorks, Inc.

    validateInputsForBinaryComparisonFunction(A, B, 'mustBeLessThanOrEqual');
    
    if ~all(A(:) <= B)
        throw(createValidatorExceptionWithValue(...
            createPrintableScalar(B),...
            'MATLAB:validators:mustBeLessThanOrEqualGenericText',...
            'MATLAB:validators:mustBeLessThanOrEqual'));
    end
end
