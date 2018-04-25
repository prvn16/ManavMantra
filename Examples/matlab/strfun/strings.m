%STRINGS Create array of string with no characters
%   STR = STRINGS returns a 1-by-1 string with no characters.
%
%   STR = STRINGS(N) returns an N-by-N array of strings with no characters.
%  
%   STR = STRINGS(M,N,...,P) returns an M-by-N-by-...-by-P array of strings 
%   with no characters.
%
%   STR = STRINGS([M N ... P]) returns an M-by-N-by-...-by-P array of strings 
%   with no characters.
%
%   The size inputs M, N, ..., and P must be nonnegative integers. STRINGS
%   treats negative integers as zero.
%
%   STRINGS(size(A)) returns an array of empty string elements that is the
%   same size as A.
%
%   Example:
%       STR = strings
%
%       returns
%
%            ""
%
%   Example:
%       STR = strings(2,3)
%
%       returns
%
%           ""    ""    ""
%           ""    ""    ""
%
%   See also STRING, ISSTRING, STRLENGTH, COMPOSE, CHAR, CELLSTR, STRFUN.

%   Copyright 1984-2016 The MathWorks, Inc.