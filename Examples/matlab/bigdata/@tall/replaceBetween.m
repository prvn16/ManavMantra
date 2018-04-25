function s = replaceBetween(str,varargin)
%REPLACEBETWEEN Replace a substring specified by bounds with new text.
%   S = REPLACEBETWEEN(STR, START, END, TEXT)
%   S = REPLACEBETWEEN(STR, START_STR, END_STR, TEXT)
%   S = REPLACEBETWEEN(..., 'Boundaries', B)
%
%   See also REPLACEBETWEEN, TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(4,inf);

% First input must be tall string. Rest must not be.
tall.checkIsTall(upper(mfilename),1,str);
str = tall.validateType(str, mfilename, {'string'}, 1);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

s = elementfun(@(x) replaceBetween(x, varargin{:}), str);

% size and type are preserved
s.Adaptor = str.Adaptor;
end
