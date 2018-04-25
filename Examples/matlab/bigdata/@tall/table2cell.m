function c = table2cell(t)
%TABLE2CELL  Convert table to cell array.
%   C = TABLE2CELL(T)
%
%   See also: TABLE2CELL, TALL.

%   Copyright 2016 The MathWorks, Inc.

t = tall.validateType(t, mfilename, {'table', 'timetable'}, 1);

c = elementfun(@table2cell, t);
c = setKnownType(c, 'cell');
end
