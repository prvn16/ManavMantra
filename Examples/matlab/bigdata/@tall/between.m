function td = between(tt1, tt2, varargin)
%BETWEEN Difference between tall array of datetimes as calendar durations
%   D = BETWEEN(T1,T2)
%   D = BETWEEN(T1,T2,COMPONENTS)
%
%   See also DATETIME/BETWEEN.

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(2,3);
tall.checkNotTall(upper(mfilename), 2, varargin{:}); %COMPONENTS cannot be tall
allowedTypes = {'datetime', 'cellstr', 'char', 'string'};
[tt1, tt2] = tall.validateType(tt1, tt2, mfilename, ...
    allowedTypes, 1:2);

% At least one of the first two inputs must be a datetime. They don't have
% to both be tall.
clz1 = tall.getClass(tt1);
clz2 = tall.getClass(tt2);
if ~strcmp(clz1,'datetime') && ~strcmp(clz2,'datetime')
    error(message("MATLAB:bigdata:array:BetweenTallDatetime"));
end

td = slicefun(@(d1, d2) between(d1, d2, varargin{:}), tt1, tt2);
td = setKnownType(td, 'calendarDuration');
end
