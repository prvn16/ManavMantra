function mustBeNumericOrLogical(A)
%MUSTBENUMERICORLOGICAL Validate that value is numeric or logical or issue error
%   MUSTBENUMERICORLOGICAL(A) issues throws an error if A contains values that are not numeric or logical.
%   MATLAB calls isnumeric(A) to determine if A is numeric and calls
%   islogical(A) to determine if A is logical.
%
%   See also: isnumeric, islogical
        
%   Copyright 2016 The MathWorks, Inc.

    if ~isNumericOrLogical(A)
        throw(createValidatorException('MATLAB:validators:mustBeNumericOrLogical'));
    end
end

