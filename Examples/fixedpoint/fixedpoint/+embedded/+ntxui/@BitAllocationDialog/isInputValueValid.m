function isValid = isInputValueValid(value, option)
%ISINPUTVALUEVALID Checks the input value to edit boxes on the Bit Allocation
%dialog.

%   Copyright 2010 The MathWorks, Inc.


% The input value to the edit boxes should be:
% 1) Finite
% 2) Scalar
% 3) Integer valued in most cases (except overflow edit box).
% 4) Positive in most cases (except IL/FL bits edit box)
%
% The argument "option" is optional and provides a way to override the
% default conditions.


isValid = true;
if isempty(value) || ~isscalar(value) || ~isnumeric(value) ...
        || isinf(value) || isnan(value)
    isValid = false;
    return;
end

if nargin < 2
    option = '';
end

switch option
    case 'allowNonIntegerValues'
        if (value < 0)
            isValid = false;
        end
    case 'allowNegValues'
        if (value~=fix(value))
            isValid = false;
        end
    otherwise
        if (value~=fix(value)) || (value < 0)
            isValid = false;
        end
end



% [EOF]
