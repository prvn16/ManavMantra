function tf = isColonSubscript(s)
%isColonSubscript Returns TRUE if argument is a colon subscript

% Copyright 2015 The MathWorks, Inc.

tf = ischar(s) && isequal(s, ':');
end
