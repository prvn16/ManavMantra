function tf = contains(s,varargin)
%CONTAINS True if pattern is found in string.
%   TF = CONTAINS(S,PATTERN)
%   TF = CONTAINS(S,PATTERN,'IgnoreCase',IGNORE)
%
%   See also TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,4);

% First input must be tall. Rest must not be.
tall.checkNotTall(upper(mfilename), 1, varargin{:});

% This method is string-specific
s = tall.validateType(s, mfilename, {'string'}, 1);

% Result is one logical per string
tf = elementfun(@(x) contains(x,varargin{:}), s);
tf = setKnownType(tf, 'logical');
end
