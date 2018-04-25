function s = strncmpi(s1,s2,n)
%STRNCMPI Compare first N characters of strings ignoring case for Java objects.

%   Copyright 1984-2006 The MathWorks, Inc.

s = strncmpi(fromOpaque(s1),fromOpaque(s2),fromOpaque(n));



