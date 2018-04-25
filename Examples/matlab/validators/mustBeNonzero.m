function mustBeNonzero(A)
%MUSTBENONZERO Validate that value is nonzero or issue error
%   MUSTBENONZERO(A) issues an error if A contains a value that is zero.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define these methods:
%       eq, isnumeric, islogical
%
%   See also: mustBeNumericOrLogical
        
%   Copyright 2016 The MathWorks, Inc.
    
    if ~isNumericOrLogical(A)
        throw(createValidatorException('MATLAB:validators:mustBeNumericOrLogical'));
    end

    if any(A(:) == 0)
        throw(createValidatorException('MATLAB:validators:mustBeNonzero')); 
    end
end
