function mustBeNonNan(A)
%MUSTBENONNAN Validate that value is nonNaN or issue error
%   MUSTBENONNAN(A) issues an error if A contains values that are NaN. 
%   MATLAB calls isnan to determine if a value is NaN.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define an isnan method.
%
%   See also: isnan
        
%   Copyright 2016 The MathWorks, Inc.
    if any(isnan(A(:)))
        throw(createValidatorException('MATLAB:validators:mustBeNonNan'));
    end
end    
