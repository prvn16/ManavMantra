function mustBeGreaterThan(A, B)
%MUSTBEGREATERTHAN Validate that value is greater than a specified value or issue error
%   MUSTBEGREATERTHAN(A,B) issues an error if A is not greater than B.
%   MATLAB calls gt to determine if A is greater than B.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       gt, isscalar, isreal, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical, mustBeReal
     
%   Copyright 2016 The MathWorks, Inc.
    
    validateInputsForBinaryComparisonFunction(A, B, 'mustBeGreaterThan');

    if ~all(A(:) > B)
        throw(createValidatorExceptionWithValue(...
            createPrintableScalar(B),...
            'MATLAB:validators:mustBeGreaterThanGenericText',...
            'MATLAB:validators:mustBeGreaterThan'));
    end
end
