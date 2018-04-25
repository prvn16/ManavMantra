function w = width(tt)
%WIDTH Number of variables in tall table or timetable.
%   W = WIDTH(T)
%
%   See also TALL/HEIGHT, TALL/SIZE, TALL/NUMEL.

% Copyright 2015-2016 The MathWorks, Inc.

tt = tall.validateType(tt, mfilename, {'table', 'timetable'}, 1);
w = tt.Adaptor.Size(2);
end
