function tf = isValidString(arg)
% Check an input to make sure it is a valid string. Allowed types are:
% * a char array
% * a string (when enabled)
% * a cellstr

% Copyright 2015 The MathWorks, Inc.

tf = ischar(arg) ...
    || iscellstr(arg) ...
    || isstring(arg);
end % isValidString
