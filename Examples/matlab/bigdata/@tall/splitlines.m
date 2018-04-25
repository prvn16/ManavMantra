function tout = splitlines(tin)
%SPLITLINES Split string at newline characters
%
%   NEWSTR = SPLITLINES(STR)
%
%   See also STRING/SPLITLINES.

%   Copyright 2017 The MathWorks, Inc.

tin = tall.validateType(tin, mfilename, {'string', 'cellstr'}, 1);

% Just call split with an appropriate delimiter
delim = compose(["\r\n", "\n", "\r"]);
tout = split(tin, delim);

end
