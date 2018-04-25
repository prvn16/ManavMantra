function charOut = char(this)
%CHAR   FI to char conversion
%   C = CHAR(F) converts fixed-point object F to a char.
%

%   Copyright 1999-2012 The MathWorks, Inc.

charOut = char(double(this));
