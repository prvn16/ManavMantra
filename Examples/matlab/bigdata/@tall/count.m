function c = count(s,varargin)
%COUNT Returns the number of occurrences of a pattern in a string.
%   C = COUNT(S,PATTERN)
%   C = COUNT(S,PATTERN,'IgnoreCase',IGNORE)
%
%   See also TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,4);

% First input must be tall. Rest must not be.
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% This method is string-specific
s = tall.validateType(s, mfilename, {'string'}, 1);

% Result is one number per string
c = elementfun(@(x) count(x,varargin{:}), s);
c = setKnownType(c, 'double');
end
