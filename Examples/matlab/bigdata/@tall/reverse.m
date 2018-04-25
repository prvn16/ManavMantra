function a = reverse(s)
%REVERSE Reverse the order of characters in string.
%   A = REVERSE(S)
%
%   See also TALL/STRING.

%   Copyright 2016 The MathWorks, Inc.

% This method is string-specific
s = tall.validateType(s, mfilename, {'string'}, 1);

% Result is one number per string
a = elementfun(@reverse, s);
% Pure elementfun with no type or size change - copy the adaptor.
a.Adaptor = s.Adaptor;
end
