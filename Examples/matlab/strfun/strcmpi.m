%STRCMPI Compare strings or character vectors ignoring case
%   TF = STRCMPI(S1,S2) compares S1 and S2 and returns logical 1 (true)
%   if they are the same except for case, and returns logical 0 (false) 
%   otherwise. Either text input can be a character vector or a string scalar. 
%
%   TF = STRCMPI(S,A) compares S to each element of array A, where S
%   is a character vector, a string scalar, or a cell array with one
%   element, and A is a string array or a cell array of character vectors. STRCMPI 
%   returns TF, a logical array that is the same size as A and contains 
%   logical 1 (true) for those elements of A that are a match, except for 
%   case, and logical 0 (false) for those elements that are not. TF = STRCMPI(A,S) 
%   returns the same result.
%
%   TF = STRCMPI(A1,A2) compares each element of A1 to the same element in A2, 
%   where A1 and A2 are equal-size string arrays or cell arrays of character 
%   vectors. Input A1 and/or A2 can also be a character array having the number 
%   of rows as there are elements in the other argument. STRCMPI returns TF, 
%   a logical array that is the same size as A1 or A2, and contains logical 1 
%   (true) for those elements of A1 and A2 that are a match, except for case, 
%   and logical 0 (false) for those elements that are not.
%
%   When one of the inputs is an array, scalar expansion occurs as needed.
%
%   STRCMPI supports international character sets.
%
%   See also STRCMP, STRNCMP, STRNCMPI, REGEXPI, CONTAINS, STARTSWITH,
%   ENDSWITH.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.


