function mustBeNonsparse(A)
%MUSTBENONSPARSE Validate that value is nonsparse or issue error
%   MUSTBENONSPARSE(A) issues an error if A is sparse.
%   MATLAB calls issparse to determine if A is sparse.
%
%   Class support:
%   All numeric classes, logical
%   MATLAB classes that define an issparse method.
%
%   See also: mustBeNumericOrLogical, mustBeReal
        
%   Copyright 2016 The MathWorks, Inc.
    if issparse(A)
        throw(createValidatorException('MATLAB:validators:mustBeNonsparse'));
    end
end
