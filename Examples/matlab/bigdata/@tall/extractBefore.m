function s = extractBefore(str,endStr)
%EXTRACTBEFORE Create a string from part of a larger string.
%   S = EXTRACTBEFORE(STR, END)
%
%   See also TALL/STRING.

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2);

% First input must be tall string.
if ~istall(str)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
str = tall.validateType(str, mfilename, {'string'}, 1);

% Treat all inputs element-wise, wrapping char arrays if used
endStr = wrapCharInput(endStr);
s = elementfun(@extractBefore, str, endStr);

% Output is always the same size and type as the first input.
s.Adaptor = str.Adaptor;
end
