function y = castLike(prototype, value) %#codegen
% castLike  Cast value to prototype's class and attributes.
%
%   castLike(PROTOTYPE, VALUE) casts VALUE to PROTOTYPE's class and
%   attributes.  castLike is a helper function for builtin CAST.
%
%   The type of the output will be identical to the type of
%   PROTOTYPE, regardless of data type override.
%
%   See also CAST.
        
%   Copyright 2012-2014 The MathWorks, Inc.
    if ~isfi(prototype)
        error(message('fixed:fi:firstInputNotFi'));
    end
    if ~isnumeric(value) && ~islogical(value)
        error(message('fixed:coder:inputMustBeNumeric'));
    end
    y = fi(removefimath(value),numerictype(prototype),fimath(prototype),'DataTypeOverride','Off');
    if ~isfimathlocal(prototype)
        y = removefimath(y);
    end
    if ~isreal(prototype) && isreal(value)
        y = complex(y);
    end
end

