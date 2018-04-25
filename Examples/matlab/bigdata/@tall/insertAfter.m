function s = insertAfter(str,pos,text)
%INSERTAFTER Insert text after a specified position.
%   S = INSERTAFTER(STR, POS, TEXT)
%
%   See also INSERTAFTER, TALL/STRING.

%   Copyright 2016 The MathWorks, Inc.

narginchk(3,3);

% We require that the first input is the tall array and the others are
% plain strings or similarly sized tall arrays of strings. The POS input
% can also be a number.
if ~istall(str)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
str = validateAndMaybeWrap(str, mfilename, 1, {'string', 'cellstr'});
pos = validateAndMaybeWrap(pos, mfilename, 2, {'string', 'cellstr', 'numeric'});
text = validateAndMaybeWrap(text, mfilename, 3, {'string', 'cellstr'});

s = elementfun(@insertAfter, str, pos, text);

% Type is preserved, but size may have changed.
s.Adaptor = copySizeInformation(str.Adaptor, s.Adaptor);
end

function arg = validateAndMaybeWrap(arg, fcnName, argIdx, validTypes)
% Check a string input to make sure it is valid. If a char array, wrap it
% to prevent dimension expansion.
if ~istall(arg) && ischar(arg)
    arg = wrapCharInput(arg);
else
    % Check tall or local input against valid types
    arg = tall.validateType(arg, fcnName, validTypes, argIdx);
end
end % validateAndMaybeWrap

