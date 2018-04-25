function tf = startsWith(s,varargin)
%STARTSWITH True if string starts with pattern.
%   TF = STARTSWITH(S,PATTERN)
%   TF = STARTSWITH(S,PATTERN,'IgnoreCase',IGNORE)
%
%   See also TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,4);

% First input must be tall. Rest must not be.
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% This method is string-specific
s = tall.validateType(s, mfilename, {'string'}, 1);

% Result is one logical per string
tf = elementfun(@(x) startsWith(x,varargin{:}), s);
tf = setKnownType(tf, 'logical');
end
