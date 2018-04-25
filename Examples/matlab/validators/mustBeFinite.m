function mustBeFinite(A)
%MUSTBEFINITE Validate that value is finite or issue error
%   MUSTBEFINITE(A) issues an error if A contains nonfinite values.
%   MATLAB calls isfinite to determine if A is finite.
%
%   Class support:
%   All numeric clases, logical, char
%   MATLAB classes that define a isfinite method.
%    
    
%   Copyright 2016 The MathWorks, Inc.
    if ~all(isfinite(A(:)))
        throw(createValidatorException('MATLAB:validators:mustBeFinite'));
    end
end
