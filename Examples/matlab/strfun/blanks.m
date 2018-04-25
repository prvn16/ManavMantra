function b = blanks(n)
%BLANKS Character vector of blanks
%   BLANKS(n) returns a character vector of n blanks.
%   Use with DISP, e.g.  DISP(['xxx' BLANKS(20) 'yyy']).
%   DISP(BLANKS(n)') moves the cursor down n lines.
%
%   See also CLC, HOME, FORMAT.

%   Copyright 1984-2016 The MathWorks, Inc.

space = ' ';
b = space(ones(1,n));
