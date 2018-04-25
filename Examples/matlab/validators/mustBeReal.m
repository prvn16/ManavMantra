function mustBeReal(A)
%MUSTBEREAL Validate that value is real or issue error
%   MUSTBEREAL(A) issues an error if A contains nonreal values. 
%   MATLAB call isreal(A) to determine if A is real.
%
%   Class support:
%   All MATLAB classes
%
%   See also: isreal
        
%   Copyright 2016 The MathWorks, Inc.
    
    if ~isreal(A)
        throw(createValidatorException('MATLAB:validators:mustBeReal'));
    end
end
