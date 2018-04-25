%STRFIND Find one string within another
%   IND = STRFIND(TEXT,PATTERN) returns the starting indices of any 
%   occurrences of PATTERN in TEXT. TEXT may be a character vector, a 
%   string array, or cell array of character vectors.
%
%   If TEXT is a nonscalar string array or a cell array of character vectors, 
%   IND is a cell array containing the starting indices of occurrences of 
%   PATTERN in TEXT. The arrays TEXT and IND have the same shape.
%
%   IND = STRFIND(TEXT,PATTERN,'ForceCellOutput',CELLOUTPUT) forces IND 
%   to be a cell array when CELLOUTPUT is true.
%
%   Examples
%       s = 'How much wood would a woodchuck chuck?';
%       strfind(s,'a')    returns  21
%       strfind('a',s)    returns  []
%       strfind(s,'wood') returns  [10 23]
%       strfind(s,'Wood') returns  []
%       strfind(s,' ')    returns  [4 9 14 20 22 32]
%
%       s = {'How much wood'; 'would a woodchuck chuck?'};
%       strfind(s,'wo')   returns  {[10]; [1 9]}
%
%   See also STRCMP, STRNCMP, STRREP, REGEXP, CONTAINS, STARTSWITH,
%   ENDSWITH.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.

