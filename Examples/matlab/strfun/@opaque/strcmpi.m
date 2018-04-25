function s = strcmpi(s1,s2)
%STRCMPI Compare strings ignoring case for Java objects.

%   Copyright 1984-2006 The MathWorks, Inc.

s = strcmpi(fromOpaque(s1),fromOpaque(s2));



