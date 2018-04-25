%COLSTYLE Parse color and style from string.
%   [L,C,M,MSG] = COLSTYLE('linespec') parses the line specification
%   'linespec' and returns the linetype part in L, the color part in C,
%   and the marker part in M.  L,C and M are empty arguments for
%   parts that are not specified or if there is a parsing error.  In
%   case of error, MSG will contain the error message string.

%   [L,C,M,MSG] = COLSTYLE(LINESPEC, 'plot') parses LINESPEC and
%   returns 'none' instead of empty if only one of linestyle or marker
%   are specified. This is to be compatible with the behavior of PLOT
%   which interprets, for example, '-' as marker 'none' and linestyle '-'.

%   Copyright 1984-2014 The MathWorks, Inc.
%   Built-in function.
