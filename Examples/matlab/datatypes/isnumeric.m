%ISNUMERIC True for numeric arrays.
%   ISNUMERIC(A) returns true if A is a numeric array and false otherwise. 
%
%   For example, integer and float (single and double) arrays are numeric,
%   while logical, character, string, cell, and structure arrays are not.
%
%   Example:
%      isnumeric(pi)
%      returns true since pi has class double while
%      isnumeric(true)
%      returns false since true has data class logical.
%
%   See also ISA, DOUBLE, SINGLE, ISFLOAT, ISINTEGER, ISSPARSE, ISLOGICAL, ISCHAR.

%   Copyright 1984-2016 The MathWorks, Inc.

