function s = strcmp(s1,s2)
%STRCMP Compare strings for Java objects.

%   Copyright 1984-2006 The MathWorks, Inc.

s = strcmp(fromOpaque(s1),fromOpaque(s2));


