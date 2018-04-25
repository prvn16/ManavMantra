function s = strncmp(s1,s2,n)
%STRNCMP Compare first N characters of strings for Java objects.

%   Copyright 1984-2006 The MathWorks, Inc.

s = strncmp(fromOpaque(s1),fromOpaque(s2),fromOpaque(n));


