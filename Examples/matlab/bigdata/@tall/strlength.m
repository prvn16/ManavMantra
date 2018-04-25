function l = strlength(s)
%STRLENGTH Lengths of string elements.
%   L = STRLENGTH(S)
%
%   See also TALL/STRING.

%   Copyright 2016 The MathWorks, Inc.

% This method is string-specific
s = tall.validateType(s, mfilename, {'string'}, 1);

l = elementfun(@strlength, s);
l = setKnownType(l, 'double');
end
