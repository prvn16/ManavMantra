function mustBeGreaterThanOrEqual(A, B)
%MUSTBEGREATERTHANOREQUAL Validate that value is greater than or equal to a specified value or issue error
%   MUSTBEGREATERTHANOREQUAL(A,B) issues an error if A is not greater than or equal to B.
%   MATLAB calls ge to determine if A is greater than or equal to B.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       ge, isscalar, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
        
%   Copyright 2016 The MathWorks, Inc.
    
    validateInputsForBinaryComparisonFunction(A, B, 'mustBeGreaterThanOrEqual');
    
    if ~all(A(:) >= B)
        throw(createValidatorExceptionWithValue(...
            createPrintableScalar(B),...
            'MATLAB:validators:mustBeGreaterThanOrEqualGenericText',...
            'MATLAB:validators:mustBeGreaterThanOrEqual'));
    end

end

