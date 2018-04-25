%STRNCMP Compare first N characters of strings or character vectors
%   TF = STRNCMP(S1,S2,N) performs a case-sensitive comparison between the
%   first N characters of S1 and S2. The function returns logical 1 (true)
%   if they are the same and returns logical 0 (false) otherwise. Either 
%   text input can be a character vector or a string scalar.
%
%   TF = STRNCMP(S,A,N) performs a case-sensitive comparison between the 
%   first N characters of string S and the first N characters in each element 
%   of array A. S is a character vector, a string scalar, or a cell array with one element,
%   and A is a string array or a cell array of character vectors. The function 
%   returns TF, a logical array that is the same size as A and contains logical 1 
%   (true) for those elements of A that are a match, and logical 0 (false) for 
%   those elements that are not. TF = STRNCMP(A,S,N) returns the same result.
%
%   TF = STRNCMP(A1,A2,N) performs a case-sensitive comparison between the 
%   first N characters of each element of array A1 and the first N 
%   characters of the same element in array A2. Inputs A1 and A2 are equal-size 
%   string arrays or cell arrays of character vectors. Input A1 and/or A2 can 
%   also be a character array having the number of rows as there are elements 
%   in the other argument. The function returns TF, a logical array that is the same size
%   as A1 or A2, and contains logical 1 (true) for those elements of A1 and A2 
%   that are a match, and logical 0 (false) for those elements that are not.
%
%   When one of the inputs is an array, scalar expansion will occur as needed.
%
%   STRNCMP supports international character sets.
%
%   See also STRCMP, STRCMPI, STRNCMPI, REGEXP, STARTSWITH.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.


