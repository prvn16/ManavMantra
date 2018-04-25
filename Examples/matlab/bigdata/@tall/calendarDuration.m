function d = calendarDuration(varargin)
%CALENDARDURATION Create a tall array of calendar durations.
%   D = CALENDARDURATION(Y,MO,D)
%   D = CALENDARDURATION(Y,MO,D,H,MI,S)
%   D = CALENDARDURATION(Y,MO,D,T)
%   D = CALENDARDURATION([Y,MO,D])
%   D = CALENDARDURATION([Y,MO,D,H,MI,S])
%   D = CALENDARDURATION(..., 'FORMAT',FMT)
%
%   See also CALENDARDURATION/CALENDARDURATION.

%   Copyright 2016 The MathWorks, Inc.

narginchk(1,8)
d = slicefun(@(varargin) calendarDuration(varargin{:}), varargin{:});
d = setKnownType(d, 'calendarDuration');
end
