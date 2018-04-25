function tc = cellstr(t, varargin)
%CELLSTR Convert tall array to cell array of character vector
%   Supported syntaxes for tall CALENDARDURATION, DATETIME, DURATION:
%   C = CELLSTR(T)
%   C = CELLSTR(T,FMT)
%   C = CELLSTR(T,FMT,LOCALE)
%
%   Supported syntaxes for tall CATEGORICAL, tall CHAR, and tall array of
%   string: C = CELLSTR(T)
%
%   See also CELLSTR, CATEGORICAL/CELLSTR, CALENDARDURATION/CELLSTR,
%   DATETIME/CELLSTR, DURATION/CELLSTR, STRING/CELLSTR.

%   Copyright 2015-2017 The MathWorks, Inc.

% CELLSTR only allows one input unless we are dealing with datetimes or
% durations, calendarDurations.
narginchk(1, maxArgsForInput(t));

tall.checkNotTall(upper(mfilename), 1, varargin{:});
supported = {'calendarDuration', 'categorical', 'datetime', 'duration', ...
             'string', 'char', 'cell'};
t = tall.validateType(t, mfilename, supported, 1);
emptyIsAnyDim = true;
tc = stringCellstr(@cellstr, varargin, t, 'cell', emptyIsAnyDim);
end

function n = maxArgsForInput(in)
% Determine how many inputs are allowed for this input argument type
clz = tall.getClass(in);

% Date-related stuff allows three inputs, otherwise just one
if ~isempty(clz) && ismember(clz, {'datetime','duration','calendarDuration'})
    n = 3;
else
    n = 1;
end
end
