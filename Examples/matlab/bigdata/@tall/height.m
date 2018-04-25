function h = height(tt)
%HEIGHT Number of rows in tall table or timetable
%   H = HEIGHT(TT) returns the number of rows of TT as H. H is a tall array.
%
%   See also: tall/width, tall.

%   Copyright 2015-2016 The MathWorks, Inc.

tt = tall.validateType(tt, mfilename, {'table', 'timetable'}, 1);
h = size(tt, 1);
end
