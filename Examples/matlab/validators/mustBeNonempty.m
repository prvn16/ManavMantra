function mustBeNonempty(A)
%MUSTBENONEMPTY Validate that value is nonempty or issue error
%   MUSTBENONEMPTY(A) issues an error if A is empty.
%   MATLAB calls isempty to determine if A is empty.
%
%   Class support:
%   All MATLAB classes
%
%   See also: isempty

%   Copyright 2016 The MathWorks, Inc.

    if isempty(A)
        throw(createValidatorException('MATLAB:validators:mustBeNonempty'));
    end
end
