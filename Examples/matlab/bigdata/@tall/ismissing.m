function out = ismissing(in, varargin)
%ISMISSING  Find missing entries
%
%   TF = ISMISSING(A)
%   TF = ISMISSING(A,INDICATORS)
%
%   See also: ISMISSING, TALL/STANDARDIZEMISSING.

% Copyright 2015-2017 The MathWorks, Inc.

tall.checkIsTall(upper(mfilename), 1, in);
narginchk(1, 2);

in = tall.validateType(in, mfilename, ...
    {'numeric', 'logical', 'categorical', ...
    'datetime', 'duration', 'calendarDuration', ...
    'string', 'char', 'cellstr', ...
    'table', 'timetable'}, 1);

if nargin>1
    tall.checkNotTall(upper(mfilename), 1, varargin{:});
    checkMissingIndicators(varargin{1}, mfilename);
end

% We get back a tall logical with the same size as the table
out = elementfun(@(t) ismissing(t, varargin{:}), in);
out = setKnownType(out, 'logical');
end
