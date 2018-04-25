%SSCANF Read string or character vector as formatted data
%   [A,COUNT,ERRMSG,NEXTINDEX] = SSCANF(S,FORMAT,SIZE) reads text from
%   MATLAB variable S, converts it according to the format specified by
%   FORMAT, and returns it in matrix A. S can be a character vector or a 
%   string scalar. COUNT returns the number of elements successfully read. 
%   ERRMSG returns an error message if an error occurred or an empty 
%   character vector if an error did not occur. NEXTINDEX is an optional 
%   output argument specifying one more than the number of characters scanned 
%   in S.
%
%   SSCANF is the same as FSCANF except that it reads the data from
%   a MATLAB variable rather than reading it from a file.
%   
%   SIZE is optional; it puts a limit on the number of elements that
%   can be scanned from S; if not specified, SSCANF reads to the end of S;
%   if specified, valid entries are: 
%
%       N      read at most N elements into a column vector.
%       Inf    read at most to the end of S.
%       [M,N]  read at most M * N elements filling at least an
%              M-by-N matrix, in column order. N can be Inf, but not M.
%
%   If the matrix A results from using character conversions only and
%   SIZE is not of the form [M,N] then a row vector is returned.
%
%   FORMAT contains C language conversion specifications.
%   Conversion specifications involve the character %, optional
%   assignment-suppressing asterisk and width field, and conversion
%   characters d, i, o, u, x, e, f, g, s, c, and [. . .] (scanset).
%   Complete ANSI C support for these conversion characters is
%   provided consistent with 'expected' MATLAB behavior. For a complete
%   conversion character specification, see a C manual.
%
%   If a conversion character s is used, an element read may cause
%   several MATLAB matrix elements to be used, each holding one
%   character.
%
%   Mixing character and numeric conversion specifications causes the
%   resulting matrix to be numeric and any characters read to show up 
%   as their numeric values, one character per MATLAB matrix element.
%
%   Scanning to end-of-string occurs when NEXTINDEX is greater than the
%   size of S.
%
%   SSCANF differs from its C language namesake in an important respect -
%   it is "vectorized" in order to return a matrix argument. The format
%   is recycled through S until its end is reached or the amount of data 
%   specified by SIZE is converted.
%
%   For example, the statements
%
%       S = '2.7183  3.1416';
%       A = sscanf(S,'%f')
%
%   create a two element vector containing approximations to e and pi.
%
%   See also FSCANF, SPRINTF, FREAD, COMPOSE.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.

