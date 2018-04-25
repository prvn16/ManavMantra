function a = table2array(t)
%TABLE2ARRAY  Convert table to a homogeneous array.
%   A = TABLE2ARRAY(T)
%
%   See also: TABLE2ARRAY, TALL.

%   Copyright 2016 The MathWorks, Inc.

t = tall.validateType(t, mfilename, {'table', 'timetable'}, 1);
a = subsref(t, substruct('{}', {':', ':'}));
end
