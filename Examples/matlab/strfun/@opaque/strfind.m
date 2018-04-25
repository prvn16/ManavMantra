function s = strfind(s1,s2)
%STRFIND Find one string within another for Java objects.

%   Copyright 2011 The MathWorks, Inc.

s = strfind(fromOpaque(s1),fromOpaque(s2));
