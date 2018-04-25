function s = findstr(s1,s2)
%FINDSTR Find one string within another for Java objects.
%
%   FINDSTR is not recommended. Use CONTAINS or STRFIND instead.

%   Copyright 1984-2017 The MathWorks, Inc.

s = findstr(fromOpaque(s1),fromOpaque(s2));




