function out = erase(in,matchStr)
%ERASE Remove content from string.
%   MODIFIEDSTR = ERASE(ORIGSTR,MATCHSTR)
%
%   See also ERASE, TALL/STRING.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,2);

% First input must be tall string. Second must be local.
tall.checkIsTall(upper(mfilename), 1, in);
tall.checkNotTall(upper(mfilename), 1, matchStr);
in = tall.validateType(in, mfilename, {'string'}, 1);

% Element-wise in the first input
out = elementfun(@(x) erase(x,matchStr), in);
out = setKnownType(out, 'string');
end
