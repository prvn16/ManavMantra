function out = isCharOrString(args)
% This undocumented function may be removed in a future release.

%   isCharOrString -  Determines whether an input is a character or a MATLAB
%   string.
%   isCharOrString(s) returns 1 if S is a character or a string.
%   Copyright 2017 MathWorks, Inc.

out = ischar(args) || (isstring(args) && isscalar(args));
end
