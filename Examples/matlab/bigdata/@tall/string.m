function ts = string(t,varargin)
%STRING Convert a tall array to a tall string array
%   Support syntax for tall array:
%   TS = STRING(T)
%
%   Support syntax for tall CALENDARDURATION, DATETIME, DURATION:
%   TS = STRING(T)
%   TS = STRING(T,FMT)
%   TS = STRING(T,FMT,LOCALE)
%
%   See also TALL/CELLSTR, CALENDARDURATION/STRING, DATETIME/STRING,
%   DURATION/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,3);
tall.checkNotTall(upper(mfilename), 1, varargin{:});
emptyIsAnyDim = false;
ts = stringCellstr(@string, varargin, t, 'string', emptyIsAnyDim);
end
