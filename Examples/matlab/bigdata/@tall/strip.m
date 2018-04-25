function s = strip(m, varargin)
%STRIP Remove leading and trailing characters.
%   S = STRIP(M)
%   S = STRIP(M, SIDE)
%   S = STRIP(M, SIDE, StripCharacter)
%
%   See also TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,3);

% First input must be tall string.
if ~istall(m)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
m = tall.validateType(m, mfilename, {'string'}, 1);

% Remaining inputs must not be tall
tall.checkNotTall(upper(mfilename), 1, varargin{:});


% Now that we have the width, we can just work on each element separately
s = elementfun(@(x) strip(x,varargin{:}), m);
% Output is the same size and type as the input
s.Adaptor = m.Adaptor;
end