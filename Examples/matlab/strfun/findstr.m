%FINDSTR Find sequence of characters within string
%   FINDSTR is not recommended. Use CONTAINS or STRFIND instead.
%
%   K = FINDSTR(S1,S2) searches the longer input argument for occurrences
%   of the shorter argument, returning the starting indices of the occurrences 
%   in the double array K. If no occurrences are found,then FINDSTR returns
%   the empty array, []. S1 and S2 can be character vectors or string scalars.
%   
%   The search performed by FINDSTR is case sensitive. FINDSTR includes 
%   leading and trailing spaces in the comparison.
%   
%   FINSDTR can be useful if you are not certain whether S1 or S2 is the 
%   longer input argument.
%
%   Examples
%       s = 'How much wood would a woodchuck chuck?';
%       findstr(s,'a')    returns  21
%       findstr('a',s)    returns  21
%       findstr(s,'wood') returns  [10 23]
%       findstr(s,'Wood') returns  []
%       findstr(s,' ')    returns  [4 9 14 20 22 32]
%
%   See also STRFIND, STRCMP, STRNCMP, STRMATCH, REGEXP.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

