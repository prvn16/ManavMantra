function i = strmatch(str,strs,flag)
%STRMATCH Find possible matches for strings for Java objects.
%
%   STRMATCH is not recommended. Use STARTSWITH or VALIDATESTRING instead.
%
%   See also STRMATCH.

%   Copyright 1984-2017 The MathWorks, Inc.

if (nargin < 3)
  i = strmatch(fromOpaque(str),fromOpaque(strs));
else
  i = strmatch(fromOpaque(str),fromOpaque(strs),fromOpaque(flag));
end



