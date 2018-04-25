function x = str2double(s)
%STR2DOUBLE Convert Java string object to MATLAB double.

%   Copyright 1984-2006 The MathWorks, Inc.

x = str2double(fromOpaque(s));
